variable "name_prefix" {
  description = "Prefix for the database bootstrap resources."
  type        = string
}

variable "master_secret_arn" {
  description = "ARN of the RDS-managed master secret."
  type        = string
}

variable "application_secret_name" {
  description = "Name of the WordPress application database secret."
  type        = string
}

variable "db_endpoint" {
  description = "Private RDS endpoint."
  type        = string
}

variable "db_port" {
  description = "RDS port."
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "WordPress database name."
  type        = string
}

variable "subnet_ids" {
  description = "Private application subnet IDs for the bootstrap Lambda."
  type        = list(string)
}

variable "security_group_id" {
  description = "Application security group used by the bootstrap Lambda."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Lambda resources."
  type        = map(string)
  default     = {}
}