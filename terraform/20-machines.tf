resource "digitalocean_kubernetes_cluster" "cluster" {
  name   = var.k8s.name
  region = var.k8s.region
  version = "1.20.2-do.0"
  tags = ["cluster"]

  node_pool {
    name       = "worker-pool"
    size       = var.k8s.size
    node_count = var.k8s.count
  }
}