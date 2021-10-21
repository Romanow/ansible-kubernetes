resource "helm_release" "ingress" {
  name       = "nginx-stable"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  timeout    = 600

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_name
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-certificate-id"
    value = var.certificate_id
  }

  set {
    name  = "controller.service.httpsPort.targetPort"
    value = 80
  }
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
  count  = length(var.hostnames)
  domain = var.domain
  name   = var.hostnames[count.index]
  type   = "A"
  ttl    = 300
  value  = data.kubernetes_service.nginx-ingress.status[0].load_balancer[0].ingress[0].ip
}