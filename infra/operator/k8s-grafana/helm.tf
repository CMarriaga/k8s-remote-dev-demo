resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "7.3.10"

  set {
    name  = "adminUser"
    value = var.grafana_admin_user
  }
  set {
    name  = "adminPassword"
    value = var.grafana_admin_password
  }

  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
