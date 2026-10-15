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