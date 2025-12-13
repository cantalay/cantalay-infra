resource "kubernetes_namespace" "postgresql" {
  metadata {
    name = "database"
  }
}

# Vault → DB Password
data "vault_kv_secret_v2" "postgres" {
  mount = "kv"
  name  = "postgres/keycloak"
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  namespace  = kubernetes_namespace.postgresql.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "18.1.13"

  values = [
    file("${path.module}/values-postgresql.yaml")
  ]

  # Vault'tan PostgreSQL password inject edilmesi
  set = [
    {
      name  = "auth.password"
      value = data.vault_kv_secret_v2.postgres.data["password"]
    },
    {
      name  = "auth.postgresPassword"
      value = data.vault_kv_secret_v2.postgres.data["postgres_password"]
    }
  ]
}
