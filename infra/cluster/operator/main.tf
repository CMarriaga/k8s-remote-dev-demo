module "metrics-server" {
  source = "./metrics-server"
}

module "istio" {
  source = "./istio"

  istio_namespace           = var.istio_namespace
  istio_version             = var.istio_version
  install_ingress_gateway   = var.install_ingress_gateway
  node_security_group_id    = var.node_security_group_id
  cluster_security_group_id = var.cluster_security_group_id

  depends_on = [module.metrics-server]
}

module "prometheus" {
  source = "./prometheus"

  depends_on = [module.metrics-server]
}

module "grafana" {
  source = "./grafana"

  depends_on = [module.prometheus]
}

# module "loki" {
#   source = "./loki"

#   namespace = "observability"

#   depends_on = [module.grafana]
# }

module "jaeger" {
  source = "./jaeger"

  namespace = "observability"

  depends_on = [module.grafana]
}

module "kiali" {
  source = "./kiali"

  depends_on = [module.jaeger]
}

module "promtail" {
  source = "./promtail"

  namespace = "observability"

  depends_on = [module.grafana]
}
