locals {
  alb_arn_suffix = element(
    split("loadbalancer/", var.alb_arn),
    1
  )

  target_group_arn_suffix = element(
    split(":", var.target_group_arn),
    5
  )
}


resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-operational-alerts"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name        = "${var.name_prefix}-wordpress-ec2-high-cpu"
  alarm_description = "Average CPU utilization in the WordPress Auto Scaling Group is high."

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 300

  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  # ASG-level CPU metrics require detailed monitoring on the ASG instances.
  # Enable detailed monitoring on the EC2 launch template if you want this
  # alarm to receive data at this aggregation level.
  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  alarm_name        = "${var.name_prefix}-alb-unhealthy-targets"
  alarm_description = "One or more WordPress targets are unhealthy."

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Maximum"
  period      = 60

  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
    TargetGroup  = local.target_group_arn_suffix
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name        = "${var.name_prefix}-alb-high-elb-5xx"
  alarm_description = "The load balancer is returning an elevated number of 5xx errors."

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"
  period      = 300

  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  dimensions = {
    LoadBalancer = local.alb_arn_suffix
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name        = "${var.name_prefix}-rds-high-cpu"
  alarm_description = "RDS CPU utilization is high."

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"
  period      = 300

  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name        = "${var.name_prefix}-rds-low-free-storage"
  alarm_description = "RDS has less than 2 GiB of free storage."

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"
  statistic   = "Minimum"
  period      = 300

  threshold           = 2147483648
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "backup_failures" {
  alarm_name        = "${var.name_prefix}-backup-job-failures"
  alarm_description = "AWS Backup reports failed backup jobs for this vault."

  namespace   = "AWS/Backup"
  metric_name = "NumberOfBackupJobsFailed"
  statistic   = "Sum"
  period      = 86400

  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  dimensions = {
    BackupVaultName = var.backup_vault_name
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}
