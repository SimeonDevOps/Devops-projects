variable "name_prefix" {
  description = "Prefix for ALB resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC containing the ALB and target instances."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the ALB."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group attached to the ALB."
  type        = string
}

variable "certificate_arn" {
  description = "Validated ACM certificate ARN. Null disables HTTPS."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Tags applied to ALB resources."
  type        = map(string)
  default     = {}
}