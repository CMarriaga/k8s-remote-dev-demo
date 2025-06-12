locals {
  backend_app_name      = format("%s-backend", var.common_name)
  microservice_app_name = format("%s-microservice", var.common_name)
  frontend_app_name     = format("%s-frontend", var.common_name)

  ingress_host = (
    length(data.kubernetes_service.istio_ingressgateway.status[0].load_balancer[0].ingress) > 0 ?
    lookup(data.kubernetes_service.istio_ingressgateway.status[0].load_balancer[0].ingress[0], "hostname", null) != null ?
    data.kubernetes_service.istio_ingressgateway.status[0].load_balancer[0].ingress[0].hostname :
    data.kubernetes_service.istio_ingressgateway.status[0].load_balancer[0].ingress[0].ip
    : null
  )
}
