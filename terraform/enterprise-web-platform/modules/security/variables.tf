variable "name_prefix" {
  description = "Prefix used to name security groups."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC in which security groups are created."
  type        = string
}

variable "public_ingress_cidrs" {
  description = "IPv4 CIDR ranges allowed to reach the public load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to security groups."
  type        = map(string)
  default     = {}
}