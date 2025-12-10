resource "kubernetes_namespace" "tempo" {
  metadata {
    name = "tempo"
  }
}

resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = kubernetes_namespace.tempo.metadata[0].name

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.24.1"

  values = [
    file("${path.module}/values-tempo.yaml")
  ]

  depends_on = [
    kubernetes_namespace.tempo
  ]
}
