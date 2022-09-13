locals {
  host                   = yamldecode(base64decode(linode_lke_cluster.test_cluster.kubeconfig)).clusters.0.cluster.server
  token                  = yamldecode(base64decode(linode_lke_cluster.test_cluster.kubeconfig)).users.0.user.token
  cluster_ca_certificate = base64decode(yamldecode(base64decode(linode_lke_cluster.test_cluster.kubeconfig)).clusters.0.cluster.certificate-authority-data)
}
