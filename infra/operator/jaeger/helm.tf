resource "helm_release" "jaeger" {
  name       = "jaeger"
  namespace  = var.namespace
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"
  version    = "0.71.7"

  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
