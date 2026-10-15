variable "name_prefix" {
  description = "Prefix used to name network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones used by the platform."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets, in AZ order."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR ranges for private application subnets, in AZ order."
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR ranges for private database subnets, in AZ order."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether private application subnets receive outbound internet access through NAT."
  type        = bool
  default     = true
}

variable "nat_gateway_per_az" {
  description = "Create one NAT Gateway per AZ instead of one shared NAT Gateway."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}