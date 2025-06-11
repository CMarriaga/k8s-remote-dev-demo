resource "kubernetes_secret" "backend" {
  metadata {
    name      = format("%s-secret", local.backend_app_name)
    namespace = var.app_namespace
  }

  data = {
    db_url = var.app_auth_db_url
  }

  type = "Opaque"
}
