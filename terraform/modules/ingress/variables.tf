variable "domain" {
  type = string
}

variable "loadbalancer_name" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "hostnames" {
  type = list(string)
}