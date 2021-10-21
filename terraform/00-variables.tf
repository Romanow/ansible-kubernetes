variable "do_token" {
  type = string
}

variable "cluster_tag" {
  type    = string
  default = "k8s-cluster"
}

variable "domain" {
  type    = string
  default = "romanow-alex.ru"
}

variable "istio_version" {
  type    = string
  default = "1.12.0-alpha.5"
}

variable "k8s" {
  type    = object({
    loadbalancer = object({
      name = string
      type = string
    })
    count        = number
    region       = string
    name         = string
    size         = string
  })
  default = {
    loadbalancer = {
      name = "loadbalancer"
      type = "gateway"
    }
    count        = 3
    region       = "ams3"
    name         = "k8s-cluster"
    size         = "s-2vcpu-4gb"
  }

  validation {
    condition     = contains([
      "ingress",
      "gateway"
    ], var.k8s.loadbalancer.type)
    error_message = "Allowed values for Load Balancer type is 'Ingress' or 'Gateway'."
  }
}