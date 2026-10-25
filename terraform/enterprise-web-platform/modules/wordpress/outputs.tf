output "launch_template_id" {
  description = "WordPress launch template ID."
  value       = aws_launch_template.this.id
}

output "autoscaling_group_name" {
  description = "WordPress Auto Scaling Group name."
  value       = aws_autoscaling_group.this.name
}

output "instance_role_arn" {
  description = "IAM role ARN assigned to WordPress instances."
  value       = aws_iam_role.ec2.arn
}

output "instance_profile_name" {
  description = "EC2 instance profile name."
  value       = aws_iam_instance_profile.this.name
}
