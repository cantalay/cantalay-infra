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

resource "kubernetes_namespace_v1" "promtail" {
  metadata {
    name = "promtail"
  }
}

resource "helm_release" "promtail" {
  name             = "promtail"
  namespace        = kubernetes_namespace_v1.promtail.metadata[0].name
  create_namespace = false

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.17.1"  # 2025| kasım için en güncel stabilize edilmiş sürüm

  values = [
    file("${path.module}/values-promtail.yaml")
  ]
}
