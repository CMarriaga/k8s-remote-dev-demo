resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "Prometheus"
  is_default = true

  url = "http://prometheus-server.monitoring.svc.cluster.local" # Adjust to your K8s service DNS
}

resource "grafana_dashboard" "node" {
  config_json = templatefile("${path.module}/dashboards/node.json", {
    prometheus_ds = "Prometheus"
  })
}

resource "grafana_dashboard" "application" {
  config_json = templatefile("${path.module}/dashboards/application.json", {
    prometheus_ds = "Prometheus"
  })
}

# resource "grafana_dashboard" "application_dashboard" {
#   config_json = file("${path.module}/dashboards/application.json")
# }
