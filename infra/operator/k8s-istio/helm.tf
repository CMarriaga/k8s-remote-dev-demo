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
      meshConfig = {
        enableTracing = true
        defaultConfig = {
          tracing = {
            sampling = 100.0
            zipkin = {
              address = format("jaeger-collector.%s.svc:9411", var.istio_namespace)
            }
          }
        }
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

  values = [
    yamlencode({
      gateways = {
        istio-ingressgateway = {
          proxyMetadata = {
            ENABLE_TRACING   = "true"
            TRACING_SAMPLING = "100"
            ZIPKIN_ADDRESS   = "jaeger-collector.${var.istio_namespace}.svc:9411"
          }
          resources = {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    })
  ]

  depends_on = [helm_release.istiod]
}
