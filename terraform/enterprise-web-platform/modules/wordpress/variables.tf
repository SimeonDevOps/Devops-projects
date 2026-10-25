variable "name_prefix" {
  description = "Prefix for WordPress compute resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the application."
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the application instances."
  type        = string
}

variable "subnet_ids" {
  description = "Private application subnet IDs."
  type        = list(string)
}

variable "security_group_id" {
  description = "Application security group."
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group to register instances with."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "EC2 root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Minimum number of WordPress instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of WordPress instances."
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Initial desired number of WordPress instances."
  type        = number
  default     = 2
}

variable "application_secret_name" {
  description = "Secrets Manager name containing the WordPress DB credentials."
  type        = string
}

variable "application_secret_arn_pattern" {
  description = "Secret ARN pattern scoped to the application database secret."
  type        = string
}

variable "db_name" {
  description = "WordPress database name."
  type        = string
}

variable "efs_file_system_id" {
  description = "EFS file system ID."
  type        = string
}

variable "efs_access_point_id" {
  description = "EFS access point ID for WordPress uploads."
  type        = string
}

variable "efs_file_system_arn" {
  description = "EFS file system ARN."
  type        = string
}

variable "efs_access_point_arn" {
  description = "EFS access point ARN."
  type        = string
}

variable "site_url" {
  description = "Canonical site URL, such as https://www.example.com. Empty means not yet configured."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to WordPress resources."
  type        = map(string)
  default     = {}
}

variable "bootstrap_log_group_name" {
  description = "CloudWatch log group for bootstrap output."
  type        = string
}

variable "apache_log_group_name" {
  description = "CloudWatch log group for Apache logs."
  type        = string
}
