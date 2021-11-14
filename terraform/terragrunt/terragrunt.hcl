terraform_version_constraint = "~> 1.0"

terraform {
  source = "${path_relative_from_include()}/../modules/k8s-main"
}

remote_state {
  backend = "local"
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
}

inputs = {
  k8s_cluster_name       = "${basename(get_terragrunt_dir())}-cluster"
  k8s_cluster_node_count = 3
  k8s_cluster_region     = "ams3"
  k8s_cluster_size       = "s-2vcpu-2gb"

  k8s_loadbalancer_type = "ingress"
  k8s_loadbalancer_name = "loadbalancer"
}