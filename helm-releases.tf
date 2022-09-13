resource "helm_release" "nginx_ingress" {
  name      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart     = "ingress-nginx"
}

#resource "helm_release" "mysql_operator" {
#  depends_on = [helm_release.nginx_ingress]
#  name  = "mysql-operator"
#  repository = "https://mysql.github.io/mysql-operator"
#  chart = "mysql-operator"
#  namespace = "mysql-operator"
#  create_namespace = true
#}
