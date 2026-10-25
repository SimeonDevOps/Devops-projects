
locals {
  log_groups = {
    bootstrap = "/${var.name_prefix}/wordpress/bootstrap"
    apache    = "/${var.name_prefix}/wordpress/apache"
  }
}

resource "aws_cloudwatch_log_group" "wordpress" {
  for_each = local.log_groups

  name              = each.value
  retention_in_days = var.retention_days

  tags = merge(var.tags, {
    Name = replace(each.value, "/", "-")
  })
}
