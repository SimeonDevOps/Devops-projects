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