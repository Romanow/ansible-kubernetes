resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.k8s_cluster_name
  region  = var.k8s_cluster_region
  version = "1.20.11-do.0"

  node_pool {
    name       = "worker-pool"
    size       = var.k8s_cluster_size
    node_count = var.k8s_cluster_node_count
    tags       = [
      var.cluster_tag
    ]
  }
}

data "digitalocean_certificate" "certificate" {
  name = var.certificate_name
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

module "nginx-ingress" {
  count             = var.k8s_loadbalancer_type == "ingress" ? 1 : 0
  source            = "./ingress"
  certificate_id    = data.digitalocean_certificate.certificate.uuid
  loadbalancer_name = var.k8s_loadbalancer_name
  domain            = var.domain
  hostnames         = [
    "k8s-cluster",
    "store",
    "order",
    "warehouse",
    "warranty",
    "grafana",
    "kibana",
    "jaeger"
  ]
}

module "istio" {
  count             = var.k8s_loadbalancer_type == "istio" ? 1 : 0
  source            = "./istio"
  certificate_id    = data.digitalocean_certificate.certificate.uuid
  loadbalancer_name = var.k8s_loadbalancer_name
  domain            = var.domain
  hostnames         = [
    "k8s-cluster",
    "book-store",
    "grafana",
    "tracing",
    "kiali",
    "store"
  ]
}