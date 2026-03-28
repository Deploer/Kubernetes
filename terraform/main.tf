terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.0.3"
    }
  }
}

# Пустые блоки провайдеров — они будут использовать ~/.kube/config автоматически
provider "kubernetes" {}
provider "helm" {}

# 1. Создание Namespace
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

# 2. Установка ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  version    = "7.3.11"

  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
}

# 3. Настройка провайдера ArgoCD (через переменные, без вложений)
provider "argocd" {
  server_addr = "localhost:8080"
  username    = "admin"
  password    = "заглушка" # Мы обновим это позже или TF сам подхватит из секрета
  insecure    = true
}

# 4. Приложение
resource "argocd_application" "app-khl" {
  metadata {
    name      = "app-khl-service"
    namespace = "argocd"
  }
  spec {
    project = "default"
    source {
      repo_url        = "https://github.com/Deploer/Kubernetes.git"
      target_revision = "main"
      path            = "helm-khl"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "default"
    }
    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
  depends_on = [helm_release.argocd]
}