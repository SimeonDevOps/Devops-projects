resource "aws_efs_file_system" "this" {
  creation_token = var.name_prefix

  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia_days == null ? [] : [var.transition_to_ia_days]

    content {
      transition_to_ia = "AFTER_${lifecycle_policy.value}_DAYS"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs"
  })
}

resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [var.security_group_id]
}