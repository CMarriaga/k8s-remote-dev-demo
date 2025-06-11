resource "kubernetes_config_map" "backend" {
  metadata {
    name      = format("%s-config", local.backend_app_name)
    namespace = var.app_namespace
  }

  data = {
    sqs_url = var.sqs_queue_url
  }
}

resource "kubernetes_config_map" "frontend" {
  metadata {
    name      = format("%s-config", local.frontend_app_name)
    namespace = var.app_namespace
  }

  data = {
    API_URL = format("http://%s/api", local.ingress_host)
  }
}
