resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
}

resource "helm_release" "certmanager" {
  name             = "certmanager"
  namespace        = "certmanager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"

  # Install Kubernetes Custom resource definitions
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_helm" {
  depends_on = [
    helm_release.certmanager, helm_release.nginx_ingress
  ]
  create_duration = "10s"
}

#resource "helm_release" "mysql_operator" {
#  depends_on = [helm_release.nginx_ingress]
#  name  = "mysql-operator"
#  repository = "https://mysql.github.io/mysql-operator"
#  chart = "mysql-operator"
#  namespace = "mysql-operator"
#  create_namespace = true
#}
