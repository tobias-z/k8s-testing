resource "linode_lke_cluster" "test_cluster" {
  label       = "test-cluster"
  k8s_version = "1.23"
  region      = "eu-central"
  tags        = ["prod"]

  pool {
    type  = "g6-standard-1"
    count = 1
  }
}

resource "kubectl_manifest" "mysql_secret" {
  yaml_body = file("k8s/persistence/mysql/mysql-secret.yaml")
}

resource "kubectl_manifest" "mysql_configmap" {
  yaml_body = file("k8s/persistence/mysql/mysql-configmap.yaml")
}

resource "kubectl_manifest" "mysql_cluster" {
  depends_on = [kubectl_manifest.mysql_configmap, kubectl_manifest.mysql_secret, helm_release.mysql_operator]
  yaml_body  = file("k8s/persistence/mysql/mysql-cluster.yaml")
}

resource "kubectl_manifest" "deployments" {
  depends_on = [kubectl_manifest.mysql_cluster, kubernetes_ingress.ingress]
  for_each   = fileset("k8s/apps/deployments", "*")
  yaml_body  = file("k8s/apps/deployments/${each.value}")
}

resource "kubectl_manifest" "services" {
  depends_on = [kubectl_manifest.deployments]
  for_each   = fileset("k8s/apps/services", "*")
  yaml_body  = file("k8s/apps/services/${each.value}")
}

resource "kubernetes_ingress" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name        = "ingress"
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
#      "ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }
  spec {
    rule {
      host = "user-api.tobias-z.com"
      http {
        path {
          backend {
            service_name = "user-api"
            service_port = 8080
          }
          path = "/"
        }
      }
    }
  }
}

data "dns_a_record_set" "ingress-lb-ip" {
  host = kubernetes_ingress.ingress.status.0.load_balancer.0.ingress.0.hostname
}

module "domain" {
  source     = "./modules/domain"
  domain     = "tobias-z.com"
  subdomains = ["user-api.tobias-z.com"]
  email      = "tobias.zimmer007@gmail.com"
  target_ip  = data.dns_a_record_set.ingress-lb-ip.addrs.0
  ttl_sec    = 0
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = data.dns_a_record_set.ingress-lb-ip
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
output "load_balancer_ip" {
  value = kubernetes_ingress.ingress.status.0.load_balancer.0.ingress.0.ip
}
