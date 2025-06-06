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
  }
  required_version = "~>1.12.1"
}
