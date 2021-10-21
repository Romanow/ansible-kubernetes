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

// region Ingress
resource "helm_release" "ingress" {
  count      = lower(var.k8s.loadbalancer.type) == "ingress" ? 1 : 0
  name       = "nginx-stable"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  timeout    = 600

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.k8s.loadbalancer.name
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = data.digitalocean_certificate.certificate.uuid
  }

  set {
    name  = "controller.service.httpsPort.targetPort"
    value = 80
  }
}

data "kubernetes_service" "nginx-ingress" {
  count = lower(var.k8s.loadbalancer.type) == "ingress" ? 1 : 0

  metadata {
    name = "nginx-stable-nginx-ingress"
  }
  depends_on = [
    helm_release.ingress
  ]
}
// endregion

// region Istio
resource "kubernetes_namespace" "istio-system" {
  count = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0

  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio-base" {
  count      = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0
  name       = "istio-base"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio-system[0].metadata[0].name
  timeout    = 600
}

resource "helm_release" "discovery" {
  count      = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0
  name       = "discovery"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "discovery"
  namespace  = kubernetes_namespace.istio-system[0].metadata[0].name
  timeout    = 600
}

resource "helm_release" "istio-ingress" {
  count      = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0
  name       = "ingress"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "ingress"
  namespace  = kubernetes_namespace.istio-system[0].metadata[0].name
  timeout    = 600

  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.k8s.loadbalancer.name
  }

  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = data.digitalocean_certificate.certificate.uuid
  }
}

resource "helm_release" "istio-egress" {
  count      = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0
  name       = "egress"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "egress"
  namespace  = kubernetes_namespace.istio-system[0].metadata[0].name
  timeout    = 600
}

data "kubernetes_service" "istio-ingress" {
  count = lower(var.k8s.loadbalancer.type) == "gateway" ? 1 : 0

  metadata {
    name = "istio-ingressgateway"
    namespace  = kubernetes_namespace.istio-system[0].metadata[0].name
  }
  depends_on = [
    helm_release.istio-ingress
  ]
}
// endregion

resource "digitalocean_record" "base-public" {
  domain = var.domain
  name   = "k8s-cluster"
  type   = "A"
  ttl    = 300
  value  = lower(var.k8s.loadbalancer.type) == "ingress" ? data.kubernetes_service.nginx-ingress[0].status[0].load_balancer[0].ingress[0].ip : data.kubernetes_service.istio-ingress[0].status[0].load_balancer[0].ingress[0].ip
}