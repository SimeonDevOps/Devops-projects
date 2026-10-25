
output "bootstrap_log_group_name" {
  description = "CloudWatch log group for bootstrap output."
  value       = aws_cloudwatch_log_group.wordpress["bootstrap"].name
}

output "apache_log_group_name" {
  description = "CloudWatch log group for Apache logs."
  value       = aws_cloudwatch_log_group.wordpress["apache"].name
}
