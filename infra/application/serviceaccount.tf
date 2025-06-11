resource "kubernetes_service_account" "backend" {
  metadata {
    name      = var.app_service_account_name
    namespace = var.app_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.app_service_account_role_arn
    }
  }
}
