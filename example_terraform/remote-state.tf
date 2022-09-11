terraform {
  backend "remote" {
    organization = "tobias-z"
    hostname     = "app.terraform.io"
    workspaces {
      name = "k8s-testing"
    }
  }
}
