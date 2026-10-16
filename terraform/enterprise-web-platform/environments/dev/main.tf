module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
  enable_nat_gateway  = var.enable_nat_gateway
  nat_gateway_per_az  = var.nat_gateway_per_az
  tags                = local.common_tags
}

module "security" {
  source = "../../modules/security"

  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  public_ingress_cidrs = var.public_ingress_cidrs
  tags                 = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix               = "${local.name_prefix}-mysql"
  subnet_ids                = module.network.db_subnet_ids
  security_group_id         = module.security.db_security_group_id
  database_name             = var.database_name
  master_username           = var.database_master_username
  instance_class            = var.database_instance_class
  engine_version            = var.database_engine_version
  allocated_storage         = var.database_allocated_storage
  max_allocated_storage     = var.database_max_allocated_storage
  backup_retention_period   = var.database_backup_retention_period
  multi_az                  = var.database_multi_az
  deletion_protection       = var.database_deletion_protection
  skip_final_snapshot       = var.database_skip_final_snapshot
  final_snapshot_identifier = "${local.name_prefix}-mysql-final"
  tags                      = local.common_tags
}

module "efs" {
  source = "../../modules/efs"

  name_prefix           = local.name_prefix
  subnet_ids            = module.network.app_subnet_ids
  security_group_id     = module.security.efs_security_group_id
  transition_to_ia_days = var.efs_transition_to_ia_days
  tags                  = local.common_tags
}

module "db_bootstrap" {
  source = "../../modules/db_bootstrap"

  name_prefix             = local.name_prefix
  master_secret_arn       = module.rds.db_master_secret_arn
  application_secret_name = "${local.name_prefix}/wordpress/database"
  db_endpoint             = module.rds.db_endpoint
  db_port                 = module.rds.db_port
  db_name                 = module.rds.db_name

  subnet_ids        = module.network.app_subnet_ids
  security_group_id = module.security.app_security_group_id
  tags              = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  security_group_id = module.security.alb_security_group_id

  certificate_arn = local.enable_https ? aws_acm_certificate_validation.site[0].certificate_arn : null

  tags = local.common_tags
}

module "wordpress" {
  source = "../../modules/wordpress"

  name_prefix = local.name_prefix
  aws_region  = var.aws_region
  vpc_id      = module.network.vpc_id

  subnet_ids        = module.network.app_subnet_ids
  security_group_id = module.security.app_security_group_id
  target_group_arn  = module.alb.target_group_arn

  instance_type    = var.wordpress_instance_type
  root_volume_size = var.wordpress_root_volume_size
  min_size         = var.wordpress_min_size
  max_size         = var.wordpress_max_size
  desired_capacity = var.wordpress_desired_capacity

  application_secret_name        = module.db_bootstrap.application_secret_name
  application_secret_arn_pattern = module.db_bootstrap.application_secret_arn_pattern
  db_name                        = module.rds.db_name

  efs_file_system_id   = module.efs.file_system_id
  efs_access_point_id  = module.efs.wordpress_uploads_access_point_id
  efs_file_system_arn  = module.efs.file_system_arn
  efs_access_point_arn = module.efs.wordpress_uploads_access_point_arn

  site_url = local.site_url
  tags     = local.common_tags

  depends_on = [
    module.db_bootstrap,
    module.efs
  ]
}