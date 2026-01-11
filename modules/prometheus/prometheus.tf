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

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Vault → DB Password
data "vault_kv_secret_v2" "grafana_initial" {
  mount = "kv"
  name  = "monitoring/grafana"
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
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
        value = data.vault_kv_secret_v2.grafana_initial.data["initial_password"]
        }
    ]
  depends_on = [
    kubernetes_secret.grafana_keycloak
  ]
}

resource "kubernetes_secret" "grafana_keycloak" {
  metadata {
    name      = "grafana-keycloak-secret"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    GRAFANA_CLIENT_SECRET = data.vault_kv_secret_v2.grafana_initial.data["client_secret"]
  }

  type = "Opaque"
}
