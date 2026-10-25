variable "name_prefix" {
  description = "Prefix used to name AWS Backup resources."
  type        = string
}

variable "resource_arns" {
  description = "ARNs of persistent resources to include in the backup selection."
  type        = list(string)

  validation {
    condition     = length(var.resource_arns) > 0
    error_message = "At least one resource ARN must be provided."
  }
}

variable "alert_topic_arn" {
  description = "SNS topic ARN used for backup failure notifications."
  type        = string
}

variable "schedule_expression" {
  description = "AWS Backup schedule in cron format."
  type        = string
  default     = "cron(0 5 ? * SUN *)"
}

variable "delete_after_days" {
  description = "Number of days before recovery points expire."
  type        = number
  default     = 35

  validation {
    condition     = var.delete_after_days >= 1
    error_message = "delete_after_days must be at least 1."
  }
}

variable "start_window_minutes" {
  description = "Minutes AWS Backup has to start a scheduled job."
  type        = number
  default     = 60
}

variable "completion_window_minutes" {
  description = "Minutes allowed for a backup job to complete."
  type        = number
  default     = 180
}

variable "tags" {
  description = "Tags applied to backup resources."
  type        = map(string)
  default     = {}
}
