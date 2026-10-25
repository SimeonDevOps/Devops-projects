output "alert_topic_arn" {
  description = "SNS topic ARN used for operational notifications."
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of alarms managed by this module."
  value = [
    aws_cloudwatch_metric_alarm.ec2_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.alb_unhealthy_targets.alarm_name,
    aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.rds_cpu.alarm_name,
    aws_cloudwatch_metric_alarm.rds_low_storage.alarm_name,
    aws_cloudwatch_metric_alarm.backup_failures.alarm_name
  ]
}
