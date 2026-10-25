variable "name_prefix" {
  description = "Prefix used to name monitoring resources."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the application load balancer."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the WordPress target group."
  type        = string
}

variable "asg_name" {
  description = "Name of the WordPress Auto Scaling Group."
  type        = string
}

variable "rds_identifier" {
  description = "Identifier of the WordPress RDS instance."
  type        = string
}

variable "backup_vault_name" {
  description = "AWS Backup vault name to monitor."
  type        = string
}

variable "alert_email" {
  description = "Email address that will receive operational alerts."
  type        = string

  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.alert_email))
    error_message = "Provide a valid email address for alert notifications."
  }
}

variable "log_retention_days" {
  description = "Retention period for application log groups."
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "EC2 CPU alarm threshold, as a percentage."
  type        = number
  default     = 80
}

variable "alb_5xx_threshold" {
  description = "Number of ALB-generated 5xx responses per alarm period."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to monitoring resources."
  type        = map(string)
  default     = {}
}
