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

variable "certificate_name" {
  type    = string
  default = "romanow-alex-certificate"
}

variable "k8s_loadbalancer_type" {
  type        = string
  default     = "ingress"
  description = "Load balancer type"
  validation {
    condition     = contains([
      "ingress",
      "istio"
    ], var.k8s_loadbalancer_type)
    error_message = "Allowed values for Load Balancer type is 'Ingress' or 'Gateway'."
  }
}

variable "k8s_loadbalancer_name" {
  type        = string
  description = "Load balancer name"
}

variable "k8s_cluster_node_count" {
  type        = number
  description = "Cluster node count"
}

variable "k8s_cluster_name" {
  type        = string
  description = "Cluster region"
}

variable "k8s_cluster_region" {
  type        = string
  description = "Cluster region"
}

variable "k8s_cluster_size" {
  type        = string
  description = "Cluster region"
}