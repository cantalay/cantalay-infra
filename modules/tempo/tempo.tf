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

resource "kubernetes_namespace_v1" "tempo" {
  metadata {
    name = "tempo"
  }
}

resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = kubernetes_namespace_v1.tempo.metadata[0].name

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.24.1"

  values = [
    file("${path.module}/values-tempo.yaml")
  ]

  depends_on = [
    kubernetes_namespace_v1.tempo
  ]
}
