resource "null_resource" "grafana_certificate" {
  triggers = {
    yaml_hash = filesha256("${path.module}/grafana-certificate.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/grafana-certificate.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }

  depends_on = [
    helm_release.kube_prometheus_stack
  ]
}

resource "null_resource" "grafana_ingress" {
  triggers = {
    yaml_hash = filesha256("${path.module}/grafana-ingress.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/grafana-ingress.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }

  depends_on = [
    null_resource.grafana_certificate
  ]
}
