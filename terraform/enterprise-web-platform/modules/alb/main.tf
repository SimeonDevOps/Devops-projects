locals {
  alb_name = substr("${var.name_prefix}-alb", 0, 32)
  tg_name  = substr("${var.name_prefix}-wp-tg", 0, 32)

  https_enabled = var.certificate_arn != null
}

resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"

  subnets         = var.public_subnet_ids
  security_groups = [var.security_group_id]

  enable_deletion_protection = false
  drop_invalid_header_fields = true
  idle_timeout               = 60

  tags = merge(var.tags, {
    Name = local.alb_name
  })
}

resource "aws_lb_target_group" "wordpress" {
  name        = local.tg_name
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name = local.tg_name
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = local.https_enabled ? "redirect" : "forward"

    target_group_arn = local.https_enabled ? null : aws_lb_target_group.wordpress.arn

    dynamic "redirect" {
      for_each = local.https_enabled ? [1] : []

      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  tags = var.tags
}

resource "aws_lb_listener" "https" {
  count = local.https_enabled ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }

  tags = var.tags
}