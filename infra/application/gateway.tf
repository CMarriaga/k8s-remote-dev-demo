resource "kubernetes_manifest" "backend_gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata = {
      name      = format("%s-gw", local.backend_app_name)
      namespace = var.app_namespace
    }
    spec = {
      selector = {
        istio = "ingress"
      }
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = ["*"]
        }
      ]
    }
  }
}
