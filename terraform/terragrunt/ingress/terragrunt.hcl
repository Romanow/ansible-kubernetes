include "root" {
  path = find_in_parent_folders()
}

inputs = {
  k8s_cluster_node_count = 5
  k8s_cluster_size       = "s-2vcpu-4gb"
  k8s_loadbalancer_type  = "ingress"
}