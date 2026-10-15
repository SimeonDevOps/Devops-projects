output "file_system_id" {
  description = "EFS file system ID."
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "EFS file system ARN."
  value       = aws_efs_file_system.this.arn
}

output "file_system_dns_name" {
  description = "EFS DNS name."
  value       = aws_efs_file_system.this.dns_name
}

output "mount_target_ids" {
  description = "IDs of the EFS mount targets."
  value       = [for target in aws_efs_mount_target.this : target.id]
}