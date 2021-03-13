resource "digitalocean_tag" "master" {
  name = "master"
}

resource "digitalocean_tag" "worker" {
  name = "worker"
}

data "digitalocean_droplet_snapshot" "vm_snapshot" {
  name        = var.vm.image
  region      = "ams3"
  most_recent = true
}

resource "digitalocean_droplet" "vm" {
  count    = var.vm.count
  image    = data.digitalocean_droplet_snapshot.vm_snapshot.id
  name     = "vm-${count.index}"
  region   = var.vm.region
  size     = var.vm.size
  ssh_keys = [
    var.ssh_fingerprint
  ]
  tags     = [
    count.index == 0 ? digitalocean_tag.master.id : digitalocean_tag.worker.id
  ]
}


output "instance_ip_addr" {
  value       = digitalocean_droplet.vm.*.ipv4_address
  description = "The IP addresses of the deployed instances, paired with their IDs."
}