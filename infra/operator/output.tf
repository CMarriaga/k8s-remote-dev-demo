output "grafana_url" {
  value       = "http://localhost:3000"
  description = "Use port-forward to access Grafana: kubectl port-forward svc/grafana 3000:80 -n monitoring"
}

output "kiali_url" {
  value       = "http://localhost:20001/kiali"
  description = "Use port-forward: kubectl port-forward svc/kiali 20001:20001 -n istio-system"
}
