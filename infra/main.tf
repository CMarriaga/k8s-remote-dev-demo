module "vpc" {
  source = "./vpc"

  identifier      = local.identifier
  cidr_block      = var.cidr_block
  common_name     = var.common_name
  cluster_name    = local.cluster_name
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "data" {
  source = "./data"

  identifier             = local.identifier
  common_name            = var.common_name
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr_block         = module.vpc.vpc_cidr_block
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  eks_private_subnet_ids = module.vpc.eks_private_subnet_ids
  eks_public_subnet_ids  = module.vpc.eks_public_subnet_ids

  depends_on = [module.vpc]
}
