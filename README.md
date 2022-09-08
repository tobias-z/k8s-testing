# Kubernetes setup

This kubernetes setup provides an out-of-the-box solution to working with kubernetes.

## Features

- MySQL setup for scalability allowing multiple replicas
- Ingress setup to allow traffic from the outside
- As many applications as you want

## Requirements

### Local Development

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

### Production

TBA

## Installation

_Local_
```bash
sh install.sh local
```

_Production_
```bash
sh install.sh prod
```

