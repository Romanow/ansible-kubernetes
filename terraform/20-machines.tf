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

data "digitalocean_certificate" "certificate" {
  name = "romanow-alex-certificate"
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.cluster.endpoint
  token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.cluster.endpoint
    token                  = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "ingress" {
  name       = "nginx-stable"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.k8s.loadbalancer
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = data.digitalocean_certificate.certificate.uuid
  }

  set {
    name  = "controller.service.httpsPort.targetPort"
    value = 80
  }

  timeout = 600
}

data "kubernetes_service" "nginx-ingress" {
  metadata {
    name = "nginx-stable-nginx-ingress"
  }
  depends_on = [
    helm_release.ingress
  ]
}

resource "digitalocean_record" "base-public" {
  domain = var.domain
  name   = "k8s-cluster"
  type   = "A"
  ttl    = 300
  value  = data.kubernetes_service.nginx-ingress.status[0].load_balancer[0].ingress[0].ip
}