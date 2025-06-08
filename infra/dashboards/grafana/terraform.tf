terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~>3.25.2"
    }
  }

  required_version = "~>1.12.1"
}
