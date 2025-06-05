variable "istio_namespace" {
  type    = string
  default = "istio-system"
}

variable "istio_version" {
  type    = string
  default = "1.22.0"
}

variable "install_ingress_gateway" {
  type    = bool
  default = true
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

variable "node_security_group_id" {
  type     = string
  nullable = false
}
variable "cluster_security_group_id" {
  type     = string
  nullable = false
}
