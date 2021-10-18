variable "do_token" {
  type = string
}

variable "cluster_tag" {
  type = string
  default = "k8s-cluster"
}

variable "domain" {
  type = string
  default = "romanow-alex.ru"
}

variable "k8s" {
  type    = object({
    count  = number
    region = string
    name   = string
    size   = string
  })
  default = {
    count  = 3
    region = "ams3"
    name   = "k8s-cluster"
    size   = "s-2vcpu-2gb"
  }
}