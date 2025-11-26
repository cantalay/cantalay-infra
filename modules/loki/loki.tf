resource "kubernetes_namespace" "loki" {
  metadata {
    name = "loki"
  }
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace.loki.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.46.0"
  reuse_values = false
  reset_values = true

  values = [
    file("${path.module}/values-loki.yaml")
  ]

  depends_on = [
    kubernetes_namespace.loki
  ]
}