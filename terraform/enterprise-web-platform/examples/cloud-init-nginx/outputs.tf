output "instance_id" {
  description = "ID of the EC2 instance running the web server."
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address used to reach the web server."
  value = coalesce(
    try(aws_eip.web[0].public_ip, null),
    aws_instance.web.public_ip
  )
}

output "instance_public_dns" {
  description = "Public DNS hostname assigned to the EC2 instance."
  value       = aws_instance.web.public_dns
}

output "site_url" {
  description = "HTTP URL for the NGINX website."
  value = "http://${coalesce(
    try(aws_eip.web[0].public_ip, null),
    aws_instance.web.public_ip
  )}"
}

output "healthcheck_url" {
  description = "HTTP URL for the NGINX health-check endpoint."
  value = "http://${coalesce(
    try(aws_eip.web[0].public_ip, null),
    aws_instance.web.public_ip
  )}/healthz"
}

output "vpc_id" {
  description = "ID of the VPC containing the web server."
  value       = aws_vpc.this.id
}

output "security_group_id" {
  description = "ID of the security group attached to the web server."
  value       = aws_security_group.web.id
}