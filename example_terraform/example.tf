terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

provider "linode" {
  token       = var.token
  api_version = "v4beta"
}

# linode server
resource "linode_instance" "example_instance" {
  label           = "example_instance_label"
  image           = "linode/ubuntu18.04"
  region          = "eu-central"
  authorized_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPWK4W5z/J4sjt5skaK/ClvGXj1/VD2omWA4lAGVp81q tobias.zimmer007@gmail.com"
  ]

  provisioner "file" {
    source = "setup-script.sh"
    destination = "/tmp/setup-script.sh"
    connection {
      type = "ssh"
      host = self.ip_address
      user = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-script.sh",
      "/tmp/setup-script.sh",
      "sleep 1"
    ]
    connection {
      type = "ssh"
      host = self.ip_address
      user = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

resource "linode_domain" "example_domain" {
  domain    = "tobias-z.com"
  soa_email = "tobias.zimmer007@gmail.com"
  type      = "master"
  ttl_sec   = 300 # 5 min
}

resource "linode_domain_record" "example_domain_record" {
  domain_id   = linode_domain.example_domain.id
  name        = "tobias-z.com"
  record_type = "A"
  target      = linode_instance.example_instance.ip_address
  ttl_sec     = 300
}

resource "linode_firewall" "example_firewall" {
  label = "example_firewall_label"
  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [linode_instance.example_instance.id]
}

variable "token" {}
