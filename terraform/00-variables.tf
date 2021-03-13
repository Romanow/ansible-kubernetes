variable "do_token" {
  type = string
}

variable "vm" {
  type = object({
    count  = number
    region = string
    size   = string
    image  = string
  })
  default = {
    count = 1
    region = "ams3"
    size = "s-2vcpu-2gb"
    image = "base-dev-image.12-03-2021"
  }
}

variable "ssh_fingerprint" {
  type = string
  default = "be:90:43:5c:29:83:f3:87:59:14:d9:57:a7:3b:4b:32"
}