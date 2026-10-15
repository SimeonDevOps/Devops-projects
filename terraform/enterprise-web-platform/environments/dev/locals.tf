locals {
  project_slug = lower(replace(var.project_name, " ", "-"))

  name_prefix = "${local.project_slug}-${var.environment}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Client      = var.client_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}