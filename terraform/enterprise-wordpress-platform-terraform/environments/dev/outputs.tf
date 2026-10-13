output "vpc_id" {
  description = "VPC ID."
  value       = module.network.vpc_id
}

output "security_group_id" {
  description = "WordPress security group ID."
  value       = module.security_group.security_group_id
}

output "instance_id" {
  description = "WordPress EC2 instance ID."
  value       = module.wordpress.instance_id
}

output "instance_public_ip" {
  description = "WordPress public IP."
  value       = module.wordpress.instance_public_ip
}

output "instance_public_dns" {
  description = "WordPress public DNS."
  value       = module.wordpress.instance_public_dns
}

output "wordpress_url" {
  description = "Public WordPress URL."
  value       = module.wordpress.wordpress_url
}

output "wordpress_admin_url" {
  description = "WordPress administration URL."
  value       = module.wordpress.wordpress_admin_url
}