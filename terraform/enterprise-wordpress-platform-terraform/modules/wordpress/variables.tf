variable "name" {
  description = "Base name for WordPress resources."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the WordPress EC2 instance will run."
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the WordPress instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
}

variable "allocate_eip" {
  description = "Whether to assign an Elastic IP."
  type        = bool
}

variable "ami_ssm_parameter" {
  description = "SSM public parameter containing the current Ubuntu AMI ID."
  type        = string
  default     = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

variable "wordpress_version" {
  description = "WordPress version to install."
  type        = string
  default     = "latest"
}

variable "wordpress_title" {
  description = "WordPress site title."
  type        = string
}

variable "wordpress_admin_user" {
  description = "WordPress administrator username."
  type        = string
}

variable "wordpress_admin_email" {
  description = "WordPress administrator email."
  type        = string
}

variable "wordpress_admin_password" {
  description = "WordPress administrator password."
  type        = string
  sensitive   = true
}

variable "wordpress_db_name" {
  description = "WordPress database name."
  type        = string
}

variable "wordpress_db_user" {
  description = "WordPress database username."
  type        = string
}

variable "wordpress_db_password" {
  description = "WordPress database password."
  type        = string
  sensitive   = true
}

variable "site_url" {
  description = "Optional site URL."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Tags for WordPress resources."
  type        = map(string)
  default     = {}
}