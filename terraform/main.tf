terraform {
  required_providers {
    k3d = {
      source  = "pvrevoort/k3d"
      version = "0.0.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "6.1.1"
    }
  }
}

resource "k3d_cluster" "mycluster" {
  name    = "dev-cluster"
  servers = 1
  agents  = 2
  kube_api {
    host_port = 6443
  }
  port {
    host_port      = 80
    container_port = 80
    node_filters   = ["loadbalancer"]
  }
}

provider "kubernetes" {
  host                   = k3d_cluster.mycluster.credentials[0].host
  client_certificate     = k3d_cluster.mycluster.credentials[0].client_certificate
  client_key             = k3d_cluster.mycluster.credentials[0].client_key
  cluster_ca_certificate = k3d_cluster.mycluster.credentials[0].cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = k3d_cluster.mycluster.credentials[0].host
    client_certificate     = k3d_cluster.mycluster.credentials[0].client_certificate
    client_key             = k3d_cluster.mycluster.credentials[0].client_key
    cluster_ca_certificate = k3d_cluster.mycluster.credentials[0].cluster_ca_certificate
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
  depends_on = [k3d_cluster.mycluster]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.3.11"
  set {
    name  = "server.service.type"
    value = "NodePort"
  }
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }
  depends_on = [kubernetes_namespace.argocd]
}

data "kubernetes_secret" "argocd_admin_pwd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  depends_on = [helm_release.argocd]
}

provider "argocd" {
  server_addr = "localhost:8080"
  username    = "admin"
  password    = data.kubernetes_secret.argocd_admin_pwd.data["password"]
  insecure    = true
}

resource "argocd_application" "my_app" {
  metadata {
    name      = "my-web-service"
    namespace = "argocd"
  }
  spec {
    project = "default"
    source {
      repo_url        = "https://github.com/argoproj/argocd-example-apps.git"
      target_revision = "HEAD"
      path            = "guestbook"
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