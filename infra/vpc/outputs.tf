output "vpc_arn" {
  description = "ARN of the created VPC"
  value       = aws_vpc.this.arn
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "vpc_main_route_table_id" {
  description = "ID of the Main route table associated to the VPC"
  value       = aws_vpc.this.main_route_table_id
}

output "public_subnets_ids" {
  description = "List of IDs of all the created public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets_ids" {
  description = "List of IDs of all the created private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}
