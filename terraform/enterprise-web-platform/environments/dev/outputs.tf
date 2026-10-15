output "vpc_id" {
  description = "ID of the platform VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR range of the platform VPC."
  value       = module.network.vpc_cidr
}

output "availability_zones" {
  description = "Availability Zones used by the platform."
  value       = module.network.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Private database subnet IDs."
  value       = module.network.db_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = module.network.nat_gateway_ids
}

output "alb_security_group_id" {
  description = "Security group ID for the future load balancer."
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Security group ID for application instances."
  value       = module.security.app_security_group_id
}

output "db_security_group_id" {
  description = "Security group ID for RDS."
  value       = module.security.db_security_group_id
}

output "efs_security_group_id" {
  description = "Security group ID for EFS."
  value       = module.security.efs_security_group_id
}

output "db_instance_id" {
  description = "The RDS DB instance identifier."
  value       = module.rds.db_instance_id
}

output "db_endpoint" {
  description = "Private RDS endpoint."
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "RDS database port."
  value       = module.rds.db_port
}

output "db_name" {
  description = "Initial RDS database name."
  value       = module.rds.db_name
}

output "db_master_username" {
  description = "Administrative database username."
  value       = module.rds.db_master_username
}

output "db_master_secret_arn" {
  description = "ARN of the RDS-managed master secret. This is not the secret value."
  value       = module.rds.db_master_secret_arn
}

output "efs_file_system_id" {
  description = "EFS file system ID."
  value       = module.efs.file_system_id
}

output "efs_file_system_arn" {
  description = "EFS file system ARN."
  value       = module.efs.file_system_arn
}

output "efs_file_system_dns_name" {
  description = "EFS DNS name."
  value       = module.efs.file_system_dns_name
}

output "efs_mount_target_ids" {
  description = "EFS mount target IDs."
  value       = module.efs.mount_target_ids
}