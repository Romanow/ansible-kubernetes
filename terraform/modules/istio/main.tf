resource "kubernetes_namespace" "istio-system-namespace" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = kubernetes_namespace.istio-system-namespace.metadata[0].name
  timeout    = 600
  depends_on = [
    kubernetes_namespace.istio-system-namespace
  ]
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = kubernetes_namespace.istio-system-namespace.metadata[0].name
  timeout    = 600
  depends_on = [
    helm_release.base
  ]
}

resource "kubernetes_namespace" "istio-ingress-namespace" {
  metadata {
    name   = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "helm_release" "ingress" {
  name            = "istio-ingress"
  repository      = "https://istio-release.storage.googleapis.com/charts"
  chart           = "gateway"
  namespace       = kubernetes_namespace.istio-ingress-namespace.metadata[0].name
  cleanup_on_fail = true
  timeout         = 600

  set {
    name  = "annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_name
  }

  set {
    name  = "annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = var.certificate_id
  }

  set {
    name  = "annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-protocol"
    value = "http"
  }

  set {
    name  = "annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-http-ports"
    value = "80"
    type = "string"
  }

  set {
    name  = "annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-tls-ports"
    value = "443"
    type = "string"
  }

  depends_on = [
    helm_release.base,
    helm_release.istiod,
    kubernetes_namespace.istio-ingress-namespace
  ]
}

data "kubernetes_service" "ingress-service" {
  metadata {
    name      = "istio-ingress"
    namespace = kubernetes_namespace.istio-ingress-namespace.metadata[0].name
  }
  depends_on = [
    helm_release.ingress
  ]
}

resource "digitalocean_record" "base-public" {
  count  = length(var.hostnames)
  domain = var.domain
  name   = var.hostnames[count.index]
  type   = "A"
  ttl    = 300
  value  = data.kubernetes_service.ingress-service.status[0].load_balancer[0].ingress[0].ip
}