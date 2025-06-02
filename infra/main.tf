module "vpc" {
  source = "./vpc"

  identifier      = local.identifier
  cidr_block      = var.cidr_block
  common_name     = var.common_name
  environment     = var.environment
  cluster_name    = local.cluster_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}
