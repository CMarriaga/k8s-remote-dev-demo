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

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.common_name
  cluster_version = "1.29"

  subnet_ids                     = module.vpc.eks_private_subnet_ids
  vpc_id                         = module.vpc.vpc_id
  enable_irsa                    = true
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 3

      instance_types = ["t3.small"]
      subnet_ids     = module.vpc.eks_private_subnet_ids
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Name       = var.common_name
    identifier = local.identifier
    stack      = "eks"
  }
}

module "irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "irsa-demo-aws-access"
  provider_url                  = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.demo.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.app_namespace}:${var.app_service_account_name}"]

  depends_on = [module.eks]
}
