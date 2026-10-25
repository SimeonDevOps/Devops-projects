output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID for the ALB alias record."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "WordPress target group ARN."
  value       = aws_lb_target_group.wordpress.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_enabled" {
  description = "Whether HTTPS is configured."
  value       = local.https_enabled
}