data "aws_eks_cluster" "this" {
  name = var.common_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.common_name
}
