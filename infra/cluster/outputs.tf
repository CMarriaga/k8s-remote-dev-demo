output "identifier" {
  description = "Unique identifier assigned to all resources"
  value       = random_id.this.id
}

output "region" {
  description = "Unique identifier assigned to all resources"
  value       = var.region
}

output "cluster_name" {
  description = "Unique identifier assigned to all resources"
  value       = var.common_name
}

output "grafana_url" {
  value       = module.operator.grafana_url
  description = "Use port-forward to access Grafana: kubectl port-forward svc/grafana 3000:80 -n monitoring"
}

output "kiali_url" {
  value       = module.operator.kiali_url
  description = "Use port-forward: kubectl port-forward svc/kiali 20001:20001 -n istio-system"
}

output "sqs_queue_url" {
  description = "Generated URL for the Queue"
  value       = module.data.sqs_queue_url
}
