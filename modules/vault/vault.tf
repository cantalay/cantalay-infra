resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.31.0"

  values = [
    yamlencode({
      server = {
        ha = {
          enabled = false
        }
        standalone = {
          enabled = true
          config = <<-EOF
            ui = true

            storage "raft" {
              path = "/vault/data"
            }

            listener "tcp" {
              address     = "0.0.0.0:8200"
              tls_disable = 1
            }

            disable_mlock = true
          EOF
        }
      }
    })
  ]
}

resource "null_resource" "vault_dashboard_cert" {
  depends_on = [helm_release.vault]

  triggers = {
    yaml_hash = filesha256("${path.module}/dashboard-certificate.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/dashboard-certificate.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }
}

resource "null_resource" "vault_dashboard" {
  depends_on = [null_resource.vault_dashboard_cert]

  triggers = {
    yaml_hash = filesha256("${path.module}/dashboard.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/dashboard.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }
}
