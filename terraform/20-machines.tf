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
  tags     = [
    "cluster",
    count.index == 0 ? "master" : "workers"
  ]
}

output "instance_ip_addr" {
  value       = digitalocean_droplet.vm.*.ipv4_address
  description = "The IP addresses of the deployed instances, paired with their IDs."
}

output "droplet_price" {
  value       = digitalocean_droplet.vm.*.price_hourly
  description = "Droplet price per hour"
}