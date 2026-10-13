locals {
  project_slug = lower(
    replace(
      "${var.project_name}-${var.environment}",
      "_",
      "-"
    )
  )

  client_label = upper(var.client_name)

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      Client      = local.client_label
      ManagedBy   = "Terraform"
    }
  )

  selected_azs = slice(
    var.availability_zones,
    0,
    var.subnet_count
  )

  selected_subnet_cidrs = slice(
    var.public_subnet_cidrs,
    0,
    var.subnet_count
  )

  subnet_map = {
    for index in range(var.subnet_count) :
    tostring(index) => {
      cidr = local.selected_subnet_cidrs[index]
      az   = local.selected_azs[index]
      name = "${local.project_slug}-public-${index + 1}"
    }
  }

  base_ingress_rules = [
    {
      description = "Allow HTTP from the internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  https_rules = var.enable_https ? [
    {
      description = "Allow HTTPS from the internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ] : []

  ssh_rules = var.allow_ssh && length(var.ssh_cidr_blocks) > 0 ? [
    {
      description = "Restricted SSH administration"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  ] : []

  ingress_rules = concat(
    local.base_ingress_rules,
    local.https_rules,
    local.ssh_rules
  )

  egress_rules = [
    {
      description = "Allow outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  wordpress_version_effective = coalesce(
    var.wordpress_version,
    "latest"
  )

  wordpress_version_is_pinned = can(
    regex(
      "^\\d+\\.\\d+",
      local.wordpress_version_effective
    )
  )
}