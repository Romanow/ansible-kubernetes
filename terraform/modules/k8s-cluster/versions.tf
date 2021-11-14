terraform {
  required_version = ">= 0.13"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.6.0"
    }
    kubernetes   = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm         = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}