terraform {
  required_providers {
    linode = {
      source = "linode/linode"
    }
  }
}

resource "linode_domain" "the_domain" {
  domain    = var.domain
  soa_email = var.email
  type      = "master"
  ttl_sec   = var.ttl_sec
}

resource "linode_domain_record" "root_record" {
  domain_id   = linode_domain.the_domain.id
  name        = var.domain
  record_type = "A"
  target      = var.target_ip
  ttl_sec     = var.ttl_sec
}

resource "linode_domain_record" "domain_record" {
  for_each    = var.subdomains
  domain_id   = linode_domain.the_domain.id
  name        = each.value
  record_type = "A"
  target      = var.target_ip
  ttl_sec     = var.ttl_sec
}
