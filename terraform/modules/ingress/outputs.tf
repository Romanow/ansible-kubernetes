output "loadbalancer_id" {
  value = data.kubernetes_service.nginx-ingress.status[0].load_balancer[0].ingress[0].ip
}