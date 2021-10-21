resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio-base" {
  name       = "istio-base"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  timeout    = 600
  depends_on = [
    kubernetes_namespace.istio-system
  ]
}

resource "helm_release" "discovery" {
  name       = "discovery"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "discovery"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  timeout    = 600
  depends_on = [
    helm_release.istio-base
  ]
}

resource "helm_release" "istio-ingress" {
  name       = "ingress"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "ingress"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  timeout    = 600

  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_name
  }

  set {
    name  = "gateways.istio-ingressgateway.serviceAnnotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = var.certificate_id
  }
  depends_on = [
    helm_release.istio-base,
    helm_release.discovery
  ]
}

resource "helm_release" "istio-egress" {
  name       = "egress"
  repository = "https://comocomo.github.io/istio-charts"
  chart      = "egress"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  timeout    = 600
  depends_on = [
    helm_release.istio-base,
    helm_release.discovery,
    helm_release.istio-ingress
  ]
}

data "kubernetes_service" "istio-ingress" {
  metadata {
    name      = "istio-ingressgateway"
    namespace = kubernetes_namespace.istio-system.metadata[0].name
  }
  depends_on = [
    helm_release.istio-ingress
  ]
}

resource "digitalocean_record" "base-public" {
  count  = length(var.hostnames)
  domain = var.domain
  name   = var.hostnames[count.index]
  type   = "A"
  ttl    = 300
  value  = data.kubernetes_service.istio-ingress.status[0].load_balancer[0].ingress[0].ip
}