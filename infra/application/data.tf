data "aws_eks_cluster" "this" {
  name = var.common_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.common_name
}

data "kubernetes_service" "istio_ingressgateway" {
  metadata {
    name      = "istio-ingress"
    namespace = "istio-system"
  }

  depends_on = [kubernetes_manifest.backend_gateway]
}
