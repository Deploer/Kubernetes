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

# Провайдеры без вложенных блоков — они сами возьмут конфиг из ~/.kube/config
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k3d-dev-cluster"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "k3d-dev-cluster"
  }
}

# 1. Создаем Namespace
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

# 3. Настройка провайдера ArgoCD
# ВНИМАНИЕ: Пароль мы введем позже или TF возьмет его из секрета
provider "argocd" {
  server_addr = "localhost:8080"
  username    = "admin"
  password    = "password-placeholder" 
  insecure    = true
}

# 4. Ваше приложение (Guestbook для теста)
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