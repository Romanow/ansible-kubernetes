resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.k8s.name
  region  = var.k8s.region
  version = "1.20.9-do.0"

  node_pool {
    name       = "worker-pool"
    size       = var.k8s.size
    node_count = var.k8s.count
    tags       = [
      var.cluster_tag
    ]
  }
}

resource "digitalocean_certificate" "cert" {
  name    = "${var.cluster_tag}-le-cert"
  type    = "lets_encrypt"
  domains = [
    var.domain
  ]
}

resource "digitalocean_loadbalancer" "loadbalancer" {
  name   = "loadbalancer"
  region = var.k8s.region

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "https"

    target_port     = 80
    target_protocol = "http"

    certificate_name = digitalocean_certificate.cert.name
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_tag = var.cluster_tag
}

resource "digitalocean_record" "base-public" {
  domain = var.domain
  name   = "k8s-cluster"
  type   = "A"
  ttl    = 300
  value  = digitalocean_loadbalancer.loadbalancer.ip
}