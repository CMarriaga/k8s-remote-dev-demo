provider "grafana" {
  url  = "http://localhost:3000"
  auth = "${var.grafana_admin_user}:${var.grafana_admin_password}"
}
