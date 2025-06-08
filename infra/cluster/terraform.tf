terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.99.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.4"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~>2.3.7"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.13.1"
    }
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
