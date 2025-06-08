resource "helm_release" "kiali" {
  name       = "kiali"
  namespace  = "istio-system"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-operator"
  version    = "1.84.0"

  create_namespace = false

  values = [file("${path.module}/values.yaml")]
}
