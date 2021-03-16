variable "do_token" {
  type = string
}

variable "vm" {
  type    = object({
    count  = number
    region = string
    name   = string
    size   = string
    image  = string
  })
  default = {
    count  = 3
    region = "ams3"
    name   = "k8s"
    size   = "s-2vcpu-2gb"
    image  = "base-dev-image.13-03-2021"
  }
}

variable "domain" {
  type = string
  default = "romanow-alex.ru"
}