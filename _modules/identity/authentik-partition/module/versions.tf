
provider "authentik" {
  url   = var.url
  token = var.token
}


terraform {
  required_version = ">= 1.0"

  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2024.6.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
