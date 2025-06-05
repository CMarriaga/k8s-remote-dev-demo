resource "helm_release" "loki" {
  name       = "loki"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.6.3"

  create_namespace = true

  values = [file("${path.module}/values.yaml")]

  # values = [
  #   yamlencode({
  #     isDefault = true
  #     config = {
  #       table_manager = {
  #         retention_deletes_enabled = true
  #         retention_period          = "168h" # 7 days
  #       }
  #     }
  #     persistence = {
  #       enabled = false
  #     }
  #   })
  # ]
  # Disable if not needed (comment out or remove)
  # enabled = false
}
