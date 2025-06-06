output "identifier" {
  description = "Unique identifier assigned to all resources"
  value       = random_id.this.id
}

output "grafana_url" {
  value       = module.operator.grafana_url
  description = "Use port-forward to access Grafana: kubectl port-forward svc/grafana 3000:80 -n monitoring"
}

output "kiali_url" {
  value       = module.operator.kiali_url
  description = "Use port-forward: kubectl port-forward svc/kiali 20001:20001 -n istio-system"
}
