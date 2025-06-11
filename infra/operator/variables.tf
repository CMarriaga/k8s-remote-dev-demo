variable "common_name" {
  type     = string
  nullable = false
}

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

variable "node_security_group_id" {
  type     = string
  nullable = false
}
variable "cluster_security_group_id" {
  type     = string
  nullable = false
}

variable "grafana_admin_user" {
  type    = string
  default = "admin"
}

variable "grafana_admin_password" {
  type    = string
  default = "admin"
}
