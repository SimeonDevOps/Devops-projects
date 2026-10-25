
output "backup_vault_name" {
  description = "Name of the AWS Backup vault."
  value       = aws_backup_vault.this.name
}

output "backup_vault_arn" {
  description = "ARN of the AWS Backup vault."
  value       = aws_backup_vault.this.arn
}

output "backup_plan_id" {
  description = "ID of the AWS Backup plan."
  value       = aws_backup_plan.this.id
}

output "backup_selection_id" {
  description = "ID of the persistent data backup selection."
  value       = aws_backup_selection.persistent_data.id
}

output "backup_role_arn" {
  description = "IAM role assumed by AWS Backup."
  value       = aws_iam_role.backup.arn
}
