output "loadbalancer_id" {
  value = data.kubernetes_service.ingress-service.status[0].load_balancer[0].ingress[0].ip
}