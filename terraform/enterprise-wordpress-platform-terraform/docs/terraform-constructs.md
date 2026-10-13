# Terraform Constructs Demonstrated

This project intentionally demonstrates the following Terraform concepts.

## Variables

Variables are inputs to Terraform.

Example:

```hcl
variable "instance_type" {
  type    = string
  default = "t3.small"
}
