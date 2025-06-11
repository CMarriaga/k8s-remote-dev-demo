# resource "helm_release" "jaeger" {
#   name       = "jaeger"
#   namespace  = var.namespace
#   repository = "https://jaegertracing.github.io/helm-charts"
#   chart      = "jaeger"
#   version    = "0.71.0"

#   create_namespace = true

#   values = [file("${path.module}/values.yaml")]
# }

resource "kubernetes_manifest" "jaeger" {
  manifest = yamldecode(file("${path.module}/jaeger.yaml"))
}

resource "kubernetes_manifest" "jaeger-svc" {
  manifest = yamldecode(file("${path.module}/jaeger-svc.yaml"))
}
resource "kubernetes_manifest" "jaeger-collector" {
  manifest = yamldecode(file("${path.module}/jaeger-collector.yaml"))
}
resource "kubernetes_manifest" "zipkin" {
  manifest = yamldecode(file("${path.module}/zipkin.yaml"))
}
