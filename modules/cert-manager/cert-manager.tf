terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.15.1"

  values = [
    file("${path.module}/values-cert-manager.yaml")
  ]

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

resource "kubectl_manifest" "clusterissuer_prod" {
  yaml_body = file("${path.module}/cluster-issuer-production.yaml")
}