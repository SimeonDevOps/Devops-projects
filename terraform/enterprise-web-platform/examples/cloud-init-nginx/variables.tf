variable "project_name" {
  description = "Name of the platform project."
  type        = string
  default     = "enterprise-web-platform"
}

variable "environment" {
  description = "Environment in which the example is deployed."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for the example deployment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the example subnet."
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance size."
  type        = string
  default     = "t3.micro"
}

variable "site_title" {
  description = "Title displayed on the NGINX test page."
  type        = string
  default     = "Enterprise Web Platform"
}

variable "allow_ssh" {
  description = "Whether to open SSH access to the instance."
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks" {
  description = "CIDR ranges allowed to access SSH when enabled."
  type        = list(string)
  default     = []
}

variable "allocate_eip" {
  description = "Whether to allocate a static Elastic IP."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for this deployment."
  type        = map(string)

  default = {
    Owner       = "devops-portfolio"
    Application = "nginx-cloud-init"
  }
}