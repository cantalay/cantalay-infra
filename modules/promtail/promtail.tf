terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
  }
}

resource "kubernetes_namespace" "promtail" {
  metadata {
    name = "promtail"
  }
}

resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = kubernetes_namespace.promtail.metadata[0].name
  create_namespace = false

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.17.1"  # 2025| kasım için en güncel stabilize edilmiş sürüm

  values = [
    file("${path.module}/values-promtail.yaml")
  ]
}
