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

# Мы не указываем пути явно, Terraform сам найдет ~/.kube/config
provider "kubernetes" {}
provider "helm" {}

# 1. Namespace
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

# 3. Достаем пароль администратора
data "kubernetes_secret" "argocd_admin_pwd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

# 4. Настройка провайдера ArgoCD
provider "argocd" {
  server_addr = "localhost:8080"
  username    = "admin"
  password    = data.kubernetes_secret.argocd_admin_pwd.data["password"]
  insecure    = true
}

# 5. Создание приложения
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