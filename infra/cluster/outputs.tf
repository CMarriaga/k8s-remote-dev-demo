output "identifier" {
  description = "Unique identifier assigned to all resources"
  value       = random_id.this.id
}

output "common_name" {
  description = "Common name assigned across multiple resources"
  value       = var.common_name
}

output "region" {
  description = "Region to use for resource creation"
  value       = var.region
}

output "cluster_name" {
  description = "Name assigned to the cluster"
  value       = var.common_name
}

output "sqs_queue_url" {
  description = "Generated URL for the Queue"
  value       = module.data.sqs_queue_url
}

output "rds_db_url" {
  description = "Generated URL for the database"
  value       = module.data.rds_db_url
}

output "node_security_group_id" {
  description = "ID of the security groups used for the nodes"
  value       = module.eks.node_security_group_id
}

output "cluster_security_group_id" {
  description = "ID of the security groups used for the cluster"
  value       = module.eks.cluster_security_group_id
}

# TODO: [CRITICAL] This exposes the auth link for the RDS db
# For demo only purposes is ok as it is only accessible from inside the VPC
# and it's a dummy db, exposed for easy export into the application module
# Will fix later
output "app_auth_db_url" {
  description = "Auth URL for the DB"
  value       = local.app_auth_db_url
}

output "app_service_account_role_arn" {
  description = "ARN for the service account Role on AWS"
  value       = module.irsa_role.iam_role_arn
}
