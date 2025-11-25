# ☸cantalay-infra
## Terraform ile K3s Bootstrap Altyapısı (Phase 1 – Complete)

Bu proje; tek VPS üzerinde **tamamen kodlanabilir (IaC)**, 
**Terraform ile yönetilen**, 
**K3s tabanlı** bir Kubernetes altyapısı oluşturmak için hazırlanmıştır.

Bu README, **K3s cluster kurulumunun tamamlandığı** Phase-1 aşamasını içerir.

Sonraki adımlar (Traefik, Cert-Manager, Vault, Observability, Keycloak) Phase-2+ olarak eklenecektir.
---

# Genel Mimari

Bu fazda yalnızca:

- Terraform
- SSH üzerinden remote-exec
- K3s kurulumu
- kubeconfig’in local makineye aktarılması

gerçekleşir.

---

# Ön Koşullar

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





