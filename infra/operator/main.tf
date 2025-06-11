module "metrics-server" {
  source = "./k8s-metrics-server"
}

module "istio" {
  source = "./k8s-istio"

  istio_namespace           = var.istio_namespace
  istio_version             = var.istio_version
  install_ingress_gateway   = var.install_ingress_gateway
  node_security_group_id    = var.node_security_group_id
  cluster_security_group_id = var.cluster_security_group_id

  depends_on = [module.metrics-server]
}

module "prometheus" {
  source = "./k8s-prometheus"

  depends_on = [module.metrics-server]
}

module "grafana" {
  source = "./k8s-grafana"

  depends_on = [module.prometheus]
}

# module "loki" {
#   source = "./k8s-loki"

#   namespace = "observability"

#   depends_on = [module.grafana]
# }

module "jaeger" {
  source = "./k8s-jaeger"

  namespace = var.istio_namespace

  depends_on = [module.grafana]
}

module "kiali" {
  source = "./k8s-kiali"

  # depends_on = [module.jaeger]
  depends_on = [module.istio]
}

module "promtail" {
  source = "./k8s-promtail"

  namespace = "observability"

  depends_on = [module.grafana]
}

module "telepresence" {
  source = "./k8s-telepresence"

  namespace = "ambassador"

  depends_on = [module.kiali]
}
