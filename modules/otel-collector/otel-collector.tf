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
resource "kubernetes_namespace" "otel_collector" {
  metadata {
    name = "otel-collector"
  }
}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  namespace  = kubernetes_namespace.otel_collector.metadata[0].name
  chart      = "opentelemetry-collector"
  version    = "0.140.0"  # Güncel sürüm
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"

  values = [
    file("${path.module}/values-otel-collector.yaml")
  ]
}
