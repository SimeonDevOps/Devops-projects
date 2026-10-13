variable "name" {
  description = "Name of the security group."
  type        = string
}

variable "ingress_rules" {
  description = "Ingress rules to dynamically create."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "Egress rules to dynamically create."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "tags" {
  description = "Tags applied to the security group."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created."
  type        = string
}