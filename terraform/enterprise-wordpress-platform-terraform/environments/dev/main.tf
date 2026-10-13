module "network" {
  source = "../../modules/network"

  name = local.project_slug

  vpc_cidr   = var.vpc_cidr
  subnet_map = local.subnet_map
  tags       = local.common_tags
}

module "security_group" {
  source = "../../modules/security_group"

  name = local.project_slug

  vpc_id        = module.network.vpc_id
  ingress_rules = local.ingress_rules
  egress_rules  = local.egress_rules

  tags = local.common_tags
}

module "wordpress" {
  source = "../../modules/wordpress"

  name = local.project_slug

  subnet_id         = module.network.public_subnet_ids[0]
  security_group_id = module.security_group.security_group_id

  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  allocate_eip     = var.allocate_eip

  wordpress_version = local.wordpress_version_effective

  wordpress_title          = var.wordpress_title
  wordpress_admin_user     = var.wordpress_admin_user
  wordpress_admin_email    = var.wordpress_admin_email
  wordpress_admin_password = var.wordpress_admin_password

  wordpress_db_name     = var.wordpress_db_name
  wordpress_db_user     = var.wordpress_db_user
  wordpress_db_password = var.wordpress_db_password

  site_url = var.site_url

  tags = local.common_tags
}