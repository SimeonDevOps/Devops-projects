
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  vault_name = "${var.name_prefix}-backup-vault"
  plan_name  = "${var.name_prefix}-backup-plan"
}

resource "aws_backup_vault" "this" {
  name = local.vault_name

  tags = merge(var.tags, {
    Name = local.vault_name
  })
}

data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "${var.name_prefix}-backup-service-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role = aws_iam_role.backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_plan" "this" {
  name = local.plan_name

  rule {
    rule_name         = "${var.name_prefix}-weekly-backup"
    target_vault_name = aws_backup_vault.this.name
    schedule          = var.schedule_expression

    start_window      = var.start_window_minutes
    completion_window = var.completion_window_minutes

    lifecycle {
      delete_after = var.delete_after_days
    }

    recovery_point_tags = merge(var.tags, {
      BackupPlan = local.plan_name
    })
  }

  tags = var.tags
}

resource "aws_backup_selection" "persistent_data" {
  name         = "${var.name_prefix}-persistent-data"
  plan_id      = aws_backup_plan.this.id
  iam_role_arn = aws_iam_role.backup.arn
  resources    = var.resource_arns

  depends_on = [
    aws_iam_role_policy_attachment.backup
  ]
}

# Permit AWS Backup to publish notifications to the existing SNS topic.
# The policy is limited to this account and this backup vault.
data "aws_iam_policy_document" "backup_topic" {
  statement {
    sid    = "AllowAWSBackupNotifications"
    effect = "Allow"

    actions = [
      "SNS:Publish"
    ]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      var.alert_topic_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_backup_vault.this.arn]
    }
  }
}

resource "aws_sns_topic_policy" "backup_notifications" {
  arn    = var.alert_topic_arn
  policy = data.aws_iam_policy_document.backup_topic.json
}

resource "aws_backup_vault_notifications" "this" {
  backup_vault_name = aws_backup_vault.this.name
  sns_topic_arn     = var.alert_topic_arn
  backup_vault_events = [
    "BACKUP_JOB_FAILED",
    "RESTORE_JOB_FAILED"
  ]

  depends_on = [
    aws_sns_topic_policy.backup_notifications
  ]
}
