variable "aws_region" {
  description = "AWS region in which the Terraform state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
}

variable "tags" {
  description = "Standard tags applied to the Terraform state bucket."
  type        = map(string)

  default = {
    Project   = "enterprise-web-platform"
    ManagedBy = "Terraform"
    Purpose   = "Remote State"
  }
}