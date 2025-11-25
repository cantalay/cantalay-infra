resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "37.4.0"

  values = [
    file("${path.module}/values-traefik.yaml")
  ]

  depends_on = [
    kubernetes_namespace.traefik
  ]
}

resource "null_resource" "traefik_dashboard_cert" {
  depends_on = [helm_release.traefik]

  triggers = {
    yaml_hash = filesha256("${path.module}/dashboard-certificate.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/dashboard-certificate.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }
}

resource "null_resource" "traefik_dashboard" {
  depends_on = [null_resource.traefik_dashboard_cert]

  triggers = {
    yaml_hash = filesha256("${path.module}/dashboard.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/dashboard.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }
}


