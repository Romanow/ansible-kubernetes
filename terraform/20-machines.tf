data "digitalocean_droplet_snapshot" "vm_snapshot" {
  name        = var.vm.image
  region      = "ams3"
  most_recent = true
}

resource "digitalocean_droplet" "vm" {
  count  = var.vm.count
  image  = data.digitalocean_droplet_snapshot.vm_snapshot.id
  name   = "vm-${var.vm.name}-${count.index}"
  region = var.vm.region
  size   = var.vm.size
  tags   = [
    "cluster",
    count.index == 0 ? "master" : "workers"
  ]
}

resource "digitalocean_loadbalancer" "load-balancer" {
  name        = "load-balancer"
  region      = var.vm.region
  droplet_tag = "cluster"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }
}

output "instance_ip_addr" {
  value       = digitalocean_droplet.vm.*.ipv4_address
  description = "The IP addresses of the deployed instances, paired with their IDs."
}

resource "digitalocean_record" "vm-a-record" {
  count  = var.vm.count
  name   = count.index == 0 ? "master" : "worker-${count.index}"
  domain = var.domain
  type   = "A"
  ttl    = 300
  value  = element(digitalocean_droplet.vm.*.ipv4_address, count.index)
}