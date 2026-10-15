resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Public HTTP and HTTPS access to the application load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_ingress_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.public_ingress_cidrs
  }

  egress {
    description = "Outbound traffic from the load balancer"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
    Tier = "public"
  })
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Web traffic from the application load balancer only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from the ALB security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound application traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-app-sg"
    Tier = "private-app"
  })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-db-sg"
  description = "MySQL traffic from the application security group only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from WordPress application instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Outbound database traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-sg"
    Tier = "private-db"
  })
}

resource "aws_security_group" "efs" {
  name        = "${var.name_prefix}-efs-sg"
  description = "NFS traffic from the application security group only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from WordPress application instances"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Outbound EFS security group traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-sg"
    Tier = "private-storage"
  })
}