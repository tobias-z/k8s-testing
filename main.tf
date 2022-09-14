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

#resource "kubectl_manifest" "mysql_cluster" {
#  depends_on = [kubectl_manifest.mysql_configmap, kubectl_manifest.mysql_secret, helm_release.mysql_operator]
#  yaml_body  = file("k8s/persistence/mysql/mysql-cluster.yaml")
#}

resource "kubectl_manifest" "mysql_deployment" {
  yaml_body = file("k8s/persistence/mysql/mysql-test-deployment.yaml")
}

resource "kubectl_manifest" "mysql_service" {
  depends_on = [kubectl_manifest.mysql_deployment]
  yaml_body  = file("k8s/persistence/mysql/mysql-test-service.yaml")
}

resource "kubectl_manifest" "deployments" {
  depends_on = [kubectl_manifest.deployments, kubectl_manifest.mysql_service]
  for_each   = fileset("k8s/apps/deployments", "*")
  yaml_body  = file("k8s/apps/deployments/${each.value}")
}

resource "kubectl_manifest" "services" {
  depends_on = [kubectl_manifest.deployments]
  for_each   = fileset("k8s/apps/services", "*")
  yaml_body  = file("k8s/apps/services/${each.value}")
}
