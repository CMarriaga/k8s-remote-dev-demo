data "aws_eks_cluster" "this" {
  name       = var.common_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = var.common_name
  depends_on = [module.eks]
}

data "aws_iam_openid_connect_provider" "this" {
  url        = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
  depends_on = [module.eks]
}
