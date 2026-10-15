variable "name_prefix" {
  description = "Prefix used to name EFS resources."
  type        = string
}

variable "subnet_ids" {
  description = "Private application subnet IDs for EFS mount targets."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide application subnets in at least two Availability Zones."
  }
}

variable "security_group_id" {
  description = "Security group attached to EFS mount targets."
  type        = string
}

variable "transition_to_ia_days" {
  description = "Days before EFS files transition to Infrequent Access. Set to null to disable."
  type        = number
  default     = 30
  nullable    = true

  validation {
    condition = var.transition_to_ia_days == null ? true : contains(
      [7, 14, 30, 60, 90],
      var.transition_to_ia_days
    )
    error_message = "Use 7, 14, 30, 60, or 90 days, or null to disable the transition."
  }
}

variable "tags" {
  description = "Tags applied to EFS resources."
  type        = map(string)
  default     = {}
}