resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

data "vault_kv_secret_v2" "keycloak_admin" {
  mount = "kv"
  name  = "keycloak/admin"
}

data "vault_kv_secret_v2" "keycloak_db" {
  mount = "kv"
  name  = "postgres/keycloak"
}
# Create secret FIRST
resource "kubernetes_secret" "keycloak_secrets" {
  metadata {
    name      = "keycloak-secrets"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    KEYCLOAK_ADMIN_PASSWORD = data.vault_kv_secret_v2.keycloak_admin.data["password"]
    KC_DB_PASSWORD          = data.vault_kv_secret_v2.keycloak_db.data["postgres_password"]
  }
}


resource "helm_release" "keycloak" {
  name       = "keycloak"
  namespace  = kubernetes_namespace.keycloak.metadata[0].name
  repository = "https://codecentric.github.io/helm-charts"
  chart      = "keycloakx"
  version    = "7.1.5"

  values = [
    file("${path.module}/values-keycloak.yaml")
  ]
  depends_on = [
    kubernetes_secret.keycloak_secrets
  ]
}

resource "null_resource" "keycloak_dashboard_cert" {
  depends_on = [helm_release.keycloak]

  triggers = {
    yaml_hash = filesha256("${path.module}/dashboard-certificate.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/dashboard-certificate.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }
}
resource "null_resource" "keycloak_ingress" {
  triggers = {
    yaml_hash = filesha256("${path.module}/keycloak-ingress.yaml")
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/keycloak-ingress.yaml --kubeconfig=${path.root}/kubeconfig.yaml"
  }

  depends_on = [
    null_resource.keycloak_dashboard_cert
  ]
}