output "vpc_id" {
  description = "ID of the platform VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR range of the platform VPC."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the network."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs, in Availability Zone order."
  value       = [for az in var.availability_zones : aws_subnet.public[az].id]
}

output "app_subnet_ids" {
  description = "Private application subnet IDs, in Availability Zone order."
  value       = [for az in var.availability_zones : aws_subnet.app[az].id]
}

output "db_subnet_ids" {
  description = "Private database subnet IDs, in Availability Zone order."
  value       = [for az in var.availability_zones : aws_subnet.db[az].id]
}

output "public_subnet_ids_by_az" {
  description = "Map of Availability Zone names to public subnet IDs."
  value       = { for az in var.availability_zones : az => aws_subnet.public[az].id }
}

output "app_subnet_ids_by_az" {
  description = "Map of Availability Zone names to application subnet IDs."
  value       = { for az in var.availability_zones : az => aws_subnet.app[az].id }
}

output "db_subnet_ids_by_az" {
  description = "Map of Availability Zone names to database subnet IDs."
  value       = { for az in var.availability_zones : az => aws_subnet.db[az].id }
}

output "nat_gateway_ids" {
  description = "IDs of NAT Gateways created by the module."
  value       = aws_nat_gateway.this[*].id
}