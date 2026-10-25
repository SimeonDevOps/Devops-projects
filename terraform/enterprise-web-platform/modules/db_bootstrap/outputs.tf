
output "application_secret_name" {
  description = "Name of the WordPress application database secret."
  value       = var.application_secret_name
}

output "application_secret_arn" {
  description = "ARN of the WordPress application database secret."
  value       = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${var.application_secret_name}-*"
}

output "provisioning_result" {
  description = "Non-secret result from the database user provisioning invocation."
  value       = jsondecode(aws_lambda_invocation.provision_database_user.result)
}

output "application_secret_arn_pattern" {
  description = "ARN pattern for the WordPress application database secret."
  value       = "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${var.application_secret_name}-*"
}
