# ☸cantalay-infra
## Terraform ile K3s Bootstrap Altyapısı (Phase 1 – Complete)

Bu proje; tek VPS üzerinde **tamamen kodlanabilir (IaC)**, 
**Terraform ile yönetilen**, 
**K3s tabanlı** bir Kubernetes altyapısı oluşturmak için hazırlanmıştır.

# Genel Mimari
Başlamadan önce main.tf dosyasını inceleyebilirsiniz.
Öncelikle kubeconfig oluşması için init yapmadan önce module tanımlarını main.tf içinde yorum satırı haline getirebiliriz.
Bu fazda yalnızca:

- Terraform
- SSH üzerinden remote-exec
- K3s kurulumu
- kubeconfig’in local makineye aktarılması

gerçekleşir.

#DB yönlendirmesi için terminal kodu 
```bash
kubectl port-forward -n database statefulset/postgresql 5432:5432

```
# Ön Koşullar
- ssh-keygen ile oluşturulmuş SSH anahtar çiftinizin olması gerekiyor.
- bu anahtarı sunucuya kopyalayabilmeniz gerekiyor.
- böylece terraform remote-exec ile sunucuya bağlanabilir.
- aksi takdirde terraform apply başarısız olur.

## Çalıştırılabilir yap
- chmod +x cantalay-infra/k3s/install.sh
- 

### Mac üzerinde:
- Homebrew
- Terraform
- kubectl
- Helm

### Sunucuda (VPS):
- Ubuntu 24.04
- root SSH erişimi
- Public IP (ör: `45.88.10.96`)
- Sunucuda Terraform gerekmiyor (sadece Mac’te çalışacak)

---

# 1) Terraform Kurulumu (Mac)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version

brew install kubectl
kubectl version --client

brew install helm
helm version
```

# 2) SSH Anahtar Doğrulaması
# 3) Terreform Değişkenleri için terraform.tfvars Dosyası Oluşturma
# 4) terreform init & apply

```bash
cd cantalay-infra
terraform init
terraform apply
```

# 5) kubeconfig Dosyasının Doğrulanması

```bash
export KUBECONFIG=$PWD/k3s/kubeconfig
kubectl get nodes
```

- Node’un Ready durumda olduğunu görmelisiniz.
- Tebrikler! K3s cluster’ınız hazır.
- Eğer burada hata alıyorsanız, SSH anahtar doğrulamasını tekrar kontrol edin.
- SSH anahtarınızın sunucuya doğru kopyalandığından emin olun.

# 6 ) Reinstall (İsteğe Bağlı)

```bash
terraform state rm module.loki.helm_release.loki                            
terraform state rm module.promtail.helm_release.promtail
terraform state rm module.prometheus.helm_release.kube_prometheus_stack
terraform state rm module.traefik.helm_release.traefik
terraform state rm module.cert_manager.helm_release.cert_manager
terraform state rm module.cert_manager.kubectl_manifest.clusterissuer_prod
terraform state rm module.cert_manager.kubernetes_namespace.cert_manager
terraform state rm module.loki.kubernetes_namespace.loki
terraform state rm module.promtail.kubernetes_namespace.promtail
terraform state rm module.traefik.kubernetes_namespace.traefik


helm uninstall traefik -n traefik || true
helm uninstall cert-manager -n cert-manager || true
helm uninstall loki -n loki || true
helm uninstall promtail -n promtail || true
helm uninstall kube-prometheus-stack -n monitoring || true
helm uninstall tempo -n tempo || true

kubectl delete ns traefik --force --grace-period=0 || true
kubectl delete ns cert-manager --force --grace-period=0 || true
kubectl delete ns loki --force --grace-period=0 || true
kubectl delete ns promtail --force --grace-period=0 || true
kubectl delete ns monitoring --force --grace-period=0 || true
kubectl delete ns tempo --force --grace-period=0 || true
kubectl delete ns otel-collector --force --grace-period=0 || true


kubectl delete pvc traefik --force --grace-period=0 || true
kubectl delete pvc cert-manager --force --grace-period=0 || true
kubectl delete pvc loki --force --grace-period=0 || true
kubectl delete pvc promtail --force --grace-period=0 || true
kubectl delete pvc monitoring --force --grace-period=0 || true
kubectl delete pvc tempo --force --grace-period=0 || true
kubectl delete pvc otel-collector --force --grace-period=0 || true

kubectl delete crds --all

rm -f terraform.tfstate* .terraform.lock.hcl
rm -rf .terraform

terraform import module.cert_manager.kubernetes_namespace.cert_manager cert-manager      
terraform import module.loki.kubernetes_namespace.loki loki
terraform import module.promtail.kubernetes_namespace.promtail promtail 
terraform import module.tempo.kubernetes_namespace.tempo tempo
terraform import module.otel_collector.kubernetes_namespace.otel_collector otel-collector       
terraform import module.postgresql.kubernetes_namespace.postgresql database   
terraform import module.prometheus.kubernetes_namespace.monitoring monitoring                         
terraform import module.traefik.kubernetes_namespace.traefik traefik
terraform import module.vault.kubernetes_namespace.vault vault
terraform import module.keycloak.kubernetes_namespace.keycloak keycloak
terraform import module.keycloak.kubernetes_secret.keycloak_secrets keycloak/keycloak-secrets

terraform import module.cert_manager.helm_release.cert_manager cert-manager/cert-manager
terraform import module.loki.helm_release.loki loki/loki
terraform import module.promtail.helm_release.promtail promtail/promtail
terraform import module.tempo.helm_release.tempo tempo/tempo
terraform import module.otel_collector.helm_release.otel_collector otel-collector/otel-collector
terraform import module.postgresql.helm_release.postgresql database/postgresql
terraform import module.prometheus.helm_release.kube_prometheus_stack monitoring/kube-prometheus-stack
terraform import module.traefik.helm_release.traefik traefik/traefik
terraform import module.vault.helm_release.vault vault/vault
terraform import module.keycloak.helm_release.keycloak keycloak/keycloak

terraform init
terraform apply -auto-approve
```


# Sonraki Adımlar
# 6) VAULT & KEYCLOAK Kurulumu (Phase 2 – Upcoming)
Bu fazda Terraform ile Vault & Keycloak kurulumu gerçekleştirilecektir.

```bash
kubectl exec -it vault-0 -n vault -- sh
vault login
vault auth enable oidc
vault auth list
```
oidc/ görmelisin.
```bash
vault write auth/oidc/config \
  oidc_discovery_url="https://keycloak.cantalay.com/auth/realms/cantalay-infra" \
  oidc_client_id="grafana" \
  oidc_client_secret="***************secret*****************" \
  default_role="ops"
```
Success! Data written to: auth/oidc/config
```bash
vault policy write vault-admin - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF
```
Success! Uploaded policy: vault-admin
```bash
vault policy write vault-ops - <<EOF
path "*" {
  capabilities = ["read", "list"]
}
EOF
```
Success! Uploaded policy: vault-ops
kontrol için: 
```bash
vault policy list
```
burası önemli. rolü nereden alacağını belirliyoruz: 
```bash
vault write auth/oidc/role/ops \
  user_claim="preferred_username" \
  groups_claim="resource_access.grafana.roles" \
  allowed_redirect_uris="https://vault.cantalay.com/ui/vault/auth/oidc/oidc/callback" \
  policies="vault-ops"
```
Success! Data written to: auth/oidc/role/ops

```bash 
vault write auth/oidc/role/admin \
  user_claim="preferred_username" \
  groups_claim="resource_access.grafana.roles" \
  allowed_redirect_uris="https://vault.cantalay.com/ui/vault/auth/oidc/oidc/callback" \
  policies="vault-admin"
```
Success! Data written to: auth/oidc/role/admin





