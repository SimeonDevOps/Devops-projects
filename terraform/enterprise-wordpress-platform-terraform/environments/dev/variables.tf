variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "enterprise-wordpress"
}

variable "client_name" {
  description = "Client name used for documentation and tagging."
  type        = string
  default     = "Global Technology Enterprise (Simulated)"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the workload."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the workload VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones where public subnets will be created."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets."
  type        = list(string)
}

variable "subnet_count" {
  description = "Number of public subnets to create."
  type        = number
  default     = 2

  validation {
    condition = (
      var.subnet_count >= 1 &&
      var.subnet_count <= length(var.availability_zones) &&
      var.subnet_count <= length(var.public_subnet_cidrs)
    )

    error_message = "subnet_count must be at least 1 and cannot exceed the number of availability zones or subnet CIDRs."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 30
}

variable "allocate_eip" {
  description = "Whether to allocate an Elastic IP for the WordPress instance."
  type        = bool
  default     = true
}

variable "allow_ssh" {
  description = "Whether SSH should be allowed through the security group."
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR ranges allowed to SSH to the instance."
  type        = list(string)
  default     = []
}

variable "enable_https" {
  description = "Whether HTTPS port 443 should be opened. Enable only after TLS is configured."
  type        = bool
  default     = false
}

variable "wordpress_version" {
  description = "WordPress version. Leave null to use the latest release."
  type        = string
  default     = null
  nullable    = true
}

variable "wordpress_title" {
  description = "WordPress site title."
  type        = string
  default     = "Enterprise Technology Portal"
}

variable "wordpress_admin_user" {
  description = "WordPress administrator username."
  type        = string
  default     = "platformadmin"

  validation {
    condition     = can(regex("^[A-Za-z0-9._-]+$", var.wordpress_admin_user))
    error_message = "The WordPress administrator username may contain letters, numbers, dots, underscores and hyphens."
  }
}

variable "wordpress_admin_email" {
  description = "WordPress administrator email."
  type        = string
}

variable "wordpress_admin_password" {
  description = "WordPress administrator password."
  type        = string
  sensitive   = true

  validation {
    condition = can(
      regex(
        "^[A-Za-z0-9!@#%+=_-]{16,64}$",
        var.wordpress_admin_password
      )
    )

    error_message = "Use a 16-64 character password containing letters, numbers and the safe special characters ! @ # % + = _ -."
  }
}

variable "wordpress_db_name" {
  description = "WordPress database name."
  type        = string
  default     = "wordpress"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.wordpress_db_name))
    error_message = "Database name may contain only letters, numbers and underscores."
  }
}

variable "wordpress_db_user" {
  description = "WordPress database username."
  type        = string
  default     = "wordpress"

  validation {
    condition     = can(regex("^[A-Za-z0-9_]+$", var.wordpress_db_user))
    error_message = "Database username may contain only letters, numbers and underscores."
  }
}

variable "wordpress_db_password" {
  description = "WordPress database password."
  type        = string
  sensitive   = true

  validation {
    condition = can(
      regex(
        "^[A-Za-z0-9!@#%+=_-]{16,64}$",
        var.wordpress_db_password
      )
    )

    error_message = "Use a 16-64 character database password containing letters, numbers and the safe special characters ! @ # % + = _ -."
  }
}

variable "site_url" {
  description = "Optional WordPress URL. When null and EIP is enabled, the EIP address is used."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Additional project tags."
  type        = map(string)

  default = {
    Owner = "devops-portfolio"
  }
}