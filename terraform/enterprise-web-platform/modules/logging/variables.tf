
variable "name_prefix" {
  description = "Prefix used to name application log groups."
  type        = string
}

variable "retention_days" {
  description = "Number of days to retain application logs."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to log groups."
  type        = map(string)
  default     = {}
}
