#!/usr/bin/env bash

location=$1

cwd=$(dirname "$(realpath "$0")")

install_local() {
  ensure_minikube
  install_mysql
  kubectl apply -f "$cwd/ingress/local-ingress.yaml"
  if ! minikube addons list | grep enabled | grep ingress -q; then
      minikube addons enable ingress
  fi
}

install_prod() {
  install_mysql
}

ensure_minikube() {
  minikube_active=$(minikube ip)

  if [ ! "$minikube_active" ]; then
    minikube start
  fi
}

install_mysql() {
  kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-crds.yaml
  kubectl apply -f https://raw.githubusercontent.com/mysql/mysql-operator/trunk/deploy/deploy-operator.yaml
  kubectl apply -f "$cwd/persistence/mysql/mysql-configmap.yaml"
  kubectl apply -f "$cwd/persistence/mysql/mysql-secret.yaml"
  kubectl apply -f "$cwd/persistence/mysql/mysql-cluster.yaml"
  kubectl apply -f "$cwd/persistence/mysql/mysql-client.yaml"
}

case $location in
"local")
  install_local
  ;;
"prod")
  install_prod
  ;;
*)
  echo "Unknown install location provided"
  echo "Required 'local' or 'prod' but got '$location'"
  echo "Usage '$0 {local|prod}'"
  exit 1
esac