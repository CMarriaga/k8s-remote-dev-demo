resource "helm_release" "istio_base" {
  name       = "istio-base"
  namespace  = var.istio_namespace
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = var.istio_version

  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = var.istio_namespace
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = var.istio_version

  values = [
    yamlencode({
      global = {
        istioNamespace = var.istio_namespace
      }
    })
  ]

  set {
    name  = "pilot.env.VALIDATION_WEBHOOK_CONFIG_FAIL_CLOSE"
    value = "false"
  }

  set {
    name  = "pilot.resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "pilot.resources.requests.memory"
    value = "128Mi"
  }

  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  count      = var.install_ingress_gateway ? 1 : 0
  name       = "istio-ingress"
  namespace  = var.istio_namespace
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  version    = var.istio_version

  set {
    name  = "gateways.istio-ingressgateway.resources.requests.cpu"
    value = "100m"
  }
  set {
    name  = "gateways.istio-ingressgateway.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "gateways.istio-ingressgateway.resources.limits.cpu"
    value = "250m"
  }
  set {
    name  = "gateways.istio-ingressgateway.resources.limits.memory"
    value = "256Mi"
  }

  depends_on = [helm_release.istiod]
}
