output "db_instance_id" {
  description = "The RDS DB instance identifier."
  value       = aws_db_instance.this.identifier
}

output "db_instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Private DNS endpoint for the database."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database listener port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}

output "db_master_username" {
  description = "Administrative database username."
  value       = aws_db_instance.this.username
}

output "db_master_secret_arn" {
  description = "ARN of the RDS-managed master secret in Secrets Manager."
  value       = try(aws_db_instance.this.master_user_secret[0].secret_arn, null)
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name."
  value       = aws_db_subnet_group.this.name
}