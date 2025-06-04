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

output "vpc_cidr_block" {
  description = "CIDR block used for the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnets_ids" {
  description = "List of IDs of all the created public subnets"
  value       = [for subnet in values(local.public_subnets) : aws_subnet.public[subnet.cidr].id if subnet.eks_subnet == false]
}

output "private_subnets_ids" {
  description = "List of IDs of all the created private subnets"
  value       = [for subnet in values(local.private_subnets) : aws_subnet.private[subnet.cidr].id if subnet.eks_subnet == false]
}

output "eks_public_subnets_ids" {
  description = "List of IDs of all the created public subnets for EKS cluster"
  value       = [for subnet in values(local.public_subnets) : aws_subnet.public[subnet.cidr].id if subnet.eks_subnet == true]
}

output "eks_private_subnets_ids" {
  description = "List of IDs of all the created private subnets for EKS cluster"
  value       = [for subnet in values(local.private_subnets) : aws_subnet.private[subnet.cidr].id if subnet.eks_subnet == true]
}
