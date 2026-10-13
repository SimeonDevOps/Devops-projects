output "instance_id" {
  description = "ID of the WordPress EC2 instance."
  value       = aws_instance.wordpress.id
}

output "instance_public_ip" {
  description = "Public IP address of the WordPress instance."
  value = coalesce(
    try(aws_eip.wordpress[0].public_ip, null),
    aws_instance.wordpress.public_ip
  )
}

output "instance_public_dns" {
  description = "Public DNS name of the WordPress instance."
  value       = aws_instance.wordpress.public_dns
}

output "wordpress_url" {
  description = "Public URL for WordPress."
  value       = local.effective_site_url != "" ? local.effective_site_url : "http://${aws_instance.wordpress.public_ip}"
}

output "wordpress_admin_url" {
  description = "WordPress administration URL."
  value       = "${local.effective_site_url != "" ? local.effective_site_url : "http://${aws_instance.wordpress.public_ip}"}/wp-admin/"
}