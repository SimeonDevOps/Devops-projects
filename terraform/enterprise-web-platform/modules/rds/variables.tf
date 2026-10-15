variable "name_prefix" {
  description = "Prefix used to name database resources."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "RDS must use at least two subnets."
  }
}

variable "security_group_id" {
  description = "Security group that controls access to the database."
  type        = string
}

variable "database_name" {
  description = "Initial database name created by RDS."
  type        = string
  default     = "wordpress"
}

variable "master_username" {
  description = "Administrative database username. Not for application use."
  type        = string
  default     = "dbadmin"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "Optional MySQL engine version. Null lets AWS choose its default."
  type        = string
  default     = null
  nullable    = true
}

variable "allocated_storage" {
  description = "Initial database storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for RDS autoscaling in GiB."
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 1 && var.backup_retention_period <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}

variable "multi_az" {
  description = "Whether to deploy a standby in another Availability Zone."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Whether AWS should prevent accidental database deletion."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot when the database is destroyed."
  type        = bool
  default     = false
}

variable "final_snapshot_identifier" {
  description = "Unique identifier for the final snapshot created during deletion."
  type        = string
  default     = "enterprise-web-platform-final"
}

variable "tags" {
  description = "Tags applied to database resources."
  type        = map(string)
  default     = {}
}