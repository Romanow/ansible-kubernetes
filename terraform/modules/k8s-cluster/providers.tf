provider "digitalocean" {
  token = var.do_token
}

terraform {
  backend "local" {}
}