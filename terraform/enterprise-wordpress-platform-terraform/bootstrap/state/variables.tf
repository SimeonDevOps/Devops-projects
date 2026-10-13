variable "aws_region" {
  description = "AWS region where the Terraform state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state."
  type        = string
}

variable "tags" {
  description = "Tags applied to the Terraform state bucket."
  type        = map(string)

  default = {
    Project   = "enterprise-wordpress"
    ManagedBy = "Terraform"
    Purpose   = "Terraform Remote State"
  }
}