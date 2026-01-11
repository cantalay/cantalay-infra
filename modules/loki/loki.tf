terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    helm = {
      source  = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace_v1" "loki" {
  metadata {
    name = "loki"
  }
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace_v1.loki.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.46.0"
  reuse_values = false
  reset_values = true

  values = [
    file("${path.module}/values-loki.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.loki
  ]
}