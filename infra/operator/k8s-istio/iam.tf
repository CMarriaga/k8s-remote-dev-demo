resource "aws_vpc_security_group_ingress_rule" "k8s_apiserver_to_istio_webhook" {
  tags                         = { Name = "istio-webhook" }
  description                  = "Cluster control plane calls Istio webhook"
  ip_protocol                  = "tcp"
  from_port                    = 15017
  to_port                      = 15017
  security_group_id            = var.node_security_group_id
  referenced_security_group_id = var.cluster_security_group_id
}
