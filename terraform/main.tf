terraform {
  required_providers {
    k3d = {
      source  = "pvrevoort/k3d" # Сторонний провайдер для управления кластерами k3d
      version = "0.0.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# 1. Создаем сам кластер k3d
resource "k3d_cluster" "mycluster" {
  name    = "terraform-k3d"
  servers = 1
  agents  = 2

  kube_api {
    host_port = 6443
  }

  # Проброс портов для Ingress (80 и 443)
  port {
    host_port      = 80
    container_port = 80
    node_filters   = ["loadbalancer"]
  }
}

# 2. Настраиваем провайдер Kubernetes на работу с новым кластером
provider "kubernetes" {
  host                   = k3d_cluster.mycluster.credentials[0].host
  client_certificate     = k3d_cluster.mycluster.credentials[0].client_certificate
  client_key             = k3d_cluster.mycluster.credentials[0].client_key
  cluster_ca_certificate = k3d_cluster.mycluster.credentials[0].cluster_ca_certificate
}

# 3. Тестовый Namespace (проверка, что TF видит кластер)
resource "kubernetes_namespace" "example" {
  metadata {
    name = "tf-test-space"
  }
}
# # 1. Создаем пространство имен для ArgoCD
# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
#   depends_on = [k3d_cluster.mycluster]
# }

# # 2. Устанавливаем ArgoCD через Helm
# resource "helm_release" "argocd" {
#   name       = "argocd"
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-cd"
#   namespace  = kubernetes_namespace.argocd.metadata[0].name
#   version    = "7.3.11" # Рекомендуется фиксировать версию чарта

#   # Настройки для доступа к UI (через NodePort для k3d)
#   set {
#     name  = "server.service.type"
#     value = "NodePort"
#   }

#   # Отключаем TLS для упрощения тестов (опционально)
#   set {
#     name  = "server.extraArgs"
#     value = "{--insecure}"
#   }

#   depends_on = [kubernetes_namespace.argocd]
# }