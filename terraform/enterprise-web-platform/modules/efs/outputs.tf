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

output "wordpress_uploads_access_point_id" {
  description = "EFS access point for shared WordPress uploads."
  value       = aws_efs_access_point.wordpress_uploads.id
}

output "wordpress_uploads_access_point_arn" {
  description = "ARN of the EFS access point for WordPress uploads."
  value       = aws_efs_access_point.wordpress_uploads.arn
} 