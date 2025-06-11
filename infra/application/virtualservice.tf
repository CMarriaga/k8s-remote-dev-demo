resource "kubernetes_manifest" "backend_virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata = {
      name      = format("%s-vs", local.backend_app_name)
      namespace = var.app_namespace
    }
    spec = {
      hosts    = ["*"]
      gateways = [format("%s-gw", local.backend_app_name)]
      http = [
        {
          match = [
            {
              uri = {
                prefix = "/api/"
              }
            }
          ]
          rewrite = {
            uri = "/"
          }
          route = [
            {
              destination = {
                host = format("%s.%s.svc.cluster.local", local.backend_app_name, var.app_namespace)
                port = {
                  number = 80
                }
              }
            }
          ]
        },
        {
          match = [
            {
              uri = {
                prefix = "/"
              }
            }
          ]
          route = [
            {
              destination = {
                host = format("%s.%s.svc.cluster.local", local.frontend_app_name, var.app_namespace)
                port = {
                  number = 80
                }
              }
            }
          ]
        }
      ]
    }
  }
}
