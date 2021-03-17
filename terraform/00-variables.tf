variable "do_token" {
  type = string
}

variable "k8s" {
  type    = object({
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