
variable "do_token" {}
variable "pvt_key" {}

variable "environments" {
  type = map(object({
    name   = string
    region = string
    size   = string
    image  = string
  }))

  default = {
    lonelyserpent = {
      name   = "lonelyserpent"
      size   = "s-2vcpu-2gb"
      region = "sfo3"
      image  = "fedora-39-x64"
    }

    commonrosebud = {
      name   = "commonrosebud"
      size   = "s-2vcpu-2gb"
      region = "sfo3"
      image  = "fedora-39-x64"
    }

    test = {
      name = "test"
      size   = "s-2vcpu-2gb"
      region = "sfo3"
      image  = "fedora-39-x64"
    }

    production = {
      # has a larger computer for prod
      name   = "app"
      size   = "s-2vcpu-4gb"
      region = "sfo3"
      image  = "fedora-39-x64"
    }
  }
}


terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}

module "instances" {
  source = "./modules/do_instance"

  for_each = var.environments

  name   = each.value.name
  image  = each.value.image
  region = each.value.region
  size   = each.value.size

  do_token = var.do_token
  pvt_key  = var.pvt_key
}

# resource "digitalocean_domain" "default" {
#   name = "kessler.xyz"
# }

# resource "digitalocean_record" "CNAME-www" {
#   domain = "kessler.xyz"
#   type   = "CNAME"
#   name   = "www"
#   value  = "@"
# }


# set the subdomain for each system
resource "digitalocean_record" "arecords" {
  for_each = var.environments

  domain = "kessler.xyz"
  type   = "A"
  name   = each.value.name
  value  = module.instances[each.key].public_ip
  ttl    = 60
}

output "ips" {
  value = module.instances[*]
}


