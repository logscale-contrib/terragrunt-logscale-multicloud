terraform {
  required_version = ">= 1.0"

  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
