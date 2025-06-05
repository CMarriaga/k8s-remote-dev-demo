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
  source = "terraform-aws-modules/eks/aws"

  cluster_name                             = var.common_name
  cluster_version                          = "1.30"
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    vpc-cni = {
      before_compute = true
      most-recent    = true
      configuration_values = jsonencode({
        env = {
          ENABLE_POD_ENI                    = "true"
          ENABLE_PREFIX_DELEGATION          = "true"
          POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        }
        nodeAgent = {
          enablePolicyEventLogs = "true"
        }
        enableNetworkPolicy = "true"
      })
    }
  }

  subnet_ids = module.vpc.eks_private_subnet_ids
  vpc_id     = module.vpc.vpc_id

  #create_cluster_security_group = false
  #create_node_security_group    = false

  eks_managed_node_groups = {
    default = {
      desired_capacity = 3
      min_capacity     = 3
      max_capacity     = 6
      instance_types   = ["t3.medium"]
      update_config = {
        max_unavailable_percentage = 50
      }
    }
  }

  tags = {
    Name       = format("%s-cluster", var.common_name)
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

# module "irsa_loki" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "~> 5.0"

#   role_name = "irsa-loki"

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["observability:loki"]
#     }
#   }

#   role_policy_arns = {
#     s3_access = aws_iam_policy.loki_s3.arn
#   }
# }

module "operator" {
  source = "./operator"

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }

  istio_namespace           = var.istio_namespace
  istio_version             = var.istio_version
  install_ingress_gateway   = var.install_ingress_gateway
  node_security_group_id    = module.eks.node_security_group_id
  cluster_security_group_id = module.eks.cluster_security_group_id

  depends_on = [module.eks]
}
