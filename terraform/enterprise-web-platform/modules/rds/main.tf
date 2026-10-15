locals {
  db_identifier = substr(
    replace(lower(var.name_prefix), "_", "-"),
    0,
    50
  )
}

resource "aws_db_subnet_group" "this" {
  name        = "${local.db_identifier}-subnets"
  description = "Private database subnets for ${var.name_prefix}"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.db_identifier}-subnets"
  })
}

resource "aws_db_instance" "this" {
  identifier = local.db_identifier

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false

  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = true

  multi_az                   = var.multi_az
  deletion_protection        = var.deletion_protection
  auto_minor_version_upgrade = true
  apply_immediately          = false

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : var.final_snapshot_identifier

  tags = merge(var.tags, {
    Name = local.db_identifier
  })

  lifecycle {
    precondition {
      condition     = var.max_allocated_storage >= var.allocated_storage
      error_message = "max_allocated_storage must be greater than or equal to allocated_storage."
    }
  }
}