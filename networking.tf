module "domain" {
  source     = "./modules/domain"
  domain     = "tobias-z.com"
  subdomains = ["user-api.tobias-z.com"]
  email      = var.email
  target_ip  = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip
  ttl_sec    = 300
}

resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [time_sleep.wait_for_helm]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${var.email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-secret-prod
    solvers:
      - http01:
          ingress:
            class: nginx
YAML
}

resource "kubectl_manifest" "certificate" {
  depends_on = [kubectl_manifest.cluster_issuer]
  yaml_body  = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: certificate
spec:
  secretName: certificate
  dnsNames:
    - user-api.tobias-z.com
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
YAML
}

resource "kubernetes_ingress_v1" "ingress" {
  depends_on             = [kubectl_manifest.services, time_sleep.wait_for_helm, kubectl_manifest.certificate]
  wait_for_load_balancer = false
  metadata {
    name = "ingress"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/limit-connections"  = "2"  # Connections per ip (could maybe be increased)
      "nginx.ingress.kubernetes.io/limit-rpm"          = "60" # Requests per minute
    }
  }
  spec {
    tls {
      hosts = [
        "user-api.tobias-z.com"
      ]
      secret_name = "certificate"
    }
    rule {
      host = "user-api.tobias-z.com"
      http {
        path {
          backend {
            service {
              name = "user-api"
              port {
                number = 8080
              }
            }
          }
          path_type = "Prefix"
          path      = "/"
        }
      }
    }
  }
}