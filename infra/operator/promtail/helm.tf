resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.15.3"

  create_namespace = true

  values = [
    yamlencode({
      loki = {
        serviceName = "loki"
      }
    })
  ]
  # Disable if not needed (comment out or remove)
  # enabled = false
}
