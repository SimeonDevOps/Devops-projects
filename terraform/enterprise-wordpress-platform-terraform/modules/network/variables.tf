variable "name" {
  description = "Base name used for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnet_map" {
  description = "Map describing the public subnets to create."
  type = map(object({
    cidr = string
    az   = string
    name = string
  }))
}

variable "tags" {
  description = "Common tags for network resources."
  type        = map(string)
  default     = {}
}