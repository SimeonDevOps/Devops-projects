locals {
  name_prefix = lower(
    replace(
      "${var.project_name}-${var.environment}",
      "_",
      "-"
    )
  )

  common_tags = merge(
    var.tags,
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Client      = "Global Technology Enterprise Simulated"
    }
  )

  http_rule = {
    description = "Allow public HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ssh_rules = var.allow_ssh ? [
    {
      description = "Restricted administrative SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_cidr_blocks
    }
  ] : []

  ingress_rules = concat(
    [local.http_rule],
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
}