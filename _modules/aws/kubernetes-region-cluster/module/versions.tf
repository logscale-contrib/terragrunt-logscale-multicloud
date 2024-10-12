terraform {
  required_version = ">= 1.0"


  required_providers {
    dns-validation = {
      source  = "ryanfaircloth/dns-validation"
      version = "0.2.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.71.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

provider "dns-validation" {
  # Configuration options
}
