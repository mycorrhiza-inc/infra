output "public_ip" {
  value = digitalocean_droplet.this.ipv4_address
}