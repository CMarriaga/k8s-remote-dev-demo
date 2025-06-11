terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.99.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.37.1"
    }
  }

  required_version = "~>1.12.1"
}
