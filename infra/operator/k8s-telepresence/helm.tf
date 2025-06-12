resource "helm_release" "telepresence" {
  name       = "telepresence-oss"
  repository = "oci://ghcr.io/telepresenceio"
  chart      = "telepresence-oss"
  version    = "2.22.5"
  namespace  = var.namespace

  create_namespace = true

  values = [file("${path.module}/values.yaml")]
}
