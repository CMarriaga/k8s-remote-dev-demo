resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
    labels = {
      istio-injection = "enabled"
    }
  }
}
