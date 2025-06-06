# helm.tf
resource "helm_release" "prometheus" {
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.21.0"

  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
