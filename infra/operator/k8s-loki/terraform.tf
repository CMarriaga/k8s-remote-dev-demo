terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.37.1"
    }
  }

  required_version = "~>1.12.1"
}
