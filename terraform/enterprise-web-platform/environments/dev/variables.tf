variable "project_name" {
  description = "Name of the platform project."
  type        = string
  default     = "enterprise-web-platform"
}

variable "client_name" {
  description = "Simulated consulting client name."
  type        = string
  default     = "Global Technology Enterprise Simulated"
}

variable "environment" {
  description = "Environment being deployed."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR range of the platform VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones used for the initial network."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs in Availability Zone order."
  type        = list(string)
  default     = ["10.40.1.0/24", "10.40.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "Private application subnet CIDRs in Availability Zone order."
  type        = list(string)
  default     = ["10.40.11.0/24", "10.40.12.0/24"]
}

variable "db_subnet_cidrs" {
  description = "Private database subnet CIDRs in Availability Zone order."
  type        = list(string)
  default     = ["10.40.21.0/24", "10.40.22.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable outbound internet access for private application subnets."
  type        = bool
  default     = true
}

variable "nat_gateway_per_az" {
  description = "Use one NAT Gateway per Availability Zone."
  type        = bool
  default     = false
}

variable "public_ingress_cidrs" {
  description = "IPv4 ranges permitted to access the public ALB."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Additional resource tags."
  type        = map(string)
  default = {
    Owner       = "devops-portfolio"
    CostCenter  = "portfolio"
    Application = "enterprise-web-platform"
  }
}

variable "database_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "wordpress"
}

variable "database_master_username" {
  description = "Administrative RDS username. Not for application use."
  type        = string
  default     = "dbadmin"
}

variable "database_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "database_engine_version" {
  description = "Optional MySQL engine version; null uses the AWS default."
  type        = string
  default     = null
  nullable    = true
}

variable "database_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "database_max_allocated_storage" {
  description = "Maximum RDS autoscaled storage in GiB."
  type        = number
  default     = 100
}

variable "database_backup_retention_period" {
  description = "RDS automated backup retention in days."
  type        = number
  default     = 7
}

variable "database_multi_az" {
  description = "Enable RDS Multi-AZ for higher availability."
  type        = bool
  default     = false
}

variable "database_deletion_protection" {
  description = "Prevent accidental RDS deletion."
  type        = bool
  default     = true
}

variable "database_skip_final_snapshot" {
  description = "Skip a final RDS snapshot when destroying the database."
  type        = bool
  default     = false
}

variable "efs_transition_to_ia_days" {
  description = "Days before EFS files transition to Infrequent Access; null disables transition."
  type        = number
  default     = 30
  nullable    = true
}