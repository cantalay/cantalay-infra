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
# Vault → DB Password
data "vault_kv_secret_v2" "grafana_initial" {
  mount = "kv"
  name  = "grafana_initial"
}
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "79.8.0"

  values = [
    file("${path.module}/values-prometheus.yaml")
  ]
    set = [
        {
        name  = "grafana.adminPassword"
        value = data.vault_kv_secret_v2.grafana_initial.data["password"]
        }
    ]
  depends_on = [
    kubernetes_secret.grafana_keycloak
  ]
}

resource "kubernetes_secret" "grafana_keycloak" {
  metadata {
    name      = "grafana-keycloak-secret"
    namespace = "monitoring"
  }

  data = {
    GRAFANA_CLIENT_SECRET = data.vault_kv_secret_v2.grafana_initial.data["client_secret"]
  }

  type = "Opaque"
}
