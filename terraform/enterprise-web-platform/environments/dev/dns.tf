locals {
  enable_https = var.domain_name != "" && var.route53_zone_id != ""

  site_url = local.enable_https ? "https://${var.domain_name}" : ""
}

resource "aws_acm_certificate" "site" {
  count = local.enable_https ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-wordpress-certificate"
  })
}

resource "aws_route53_record" "certificate_validation" {
  count = local.enable_https ? 1 : 0

  zone_id = var.route53_zone_id

  name = tolist(
    aws_acm_certificate.site[0].domain_validation_options
  )[0].resource_record_name

  type = tolist(
    aws_acm_certificate.site[0].domain_validation_options
  )[0].resource_record_type

  records = [
    tolist(
      aws_acm_certificate.site[0].domain_validation_options
    )[0].resource_record_value
  ]

  ttl = 60
}

resource "aws_acm_certificate_validation" "site" {
  count = local.enable_https ? 1 : 0

  certificate_arn = aws_acm_certificate.site[0].arn

  validation_record_fqdns = [
    aws_route53_record.certificate_validation[0].fqdn
  ]
}

resource "aws_route53_record" "site" {
  count = local.enable_https ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}