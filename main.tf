locals {
  k3s_install = <<-EOF
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh -
  EOF
}

resource "null_resource" "install_k3s" {
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Installing K3s...'",
      local.k3s_install
    ]
  }
}

resource "null_resource" "get_kubeconfig" {
  depends_on = [null_resource.install_k3s]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/k3s",
      "cp /etc/rancher/k3s/k3s.yaml /tmp/k3s/config",
      "sed -i 's/127.0.0.1/${var.server_ip}/g' /tmp/k3s/config"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${var.ssh_user}@${var.server_ip}:/tmp/k3s/config kubeconfig.yaml"
  }
}

output "kubeconfig_file" {
  value = "${path.module}/kubeconfig.yaml"
}
# Bu çıktı, oluşturulan kubeconfig dosyasının
# yolunu gösterir.
# export KUBECONFIG=$(terraform output -raw kubeconfig_file)
# Bu komut ile kubeconfig dosyasını
# KUBECONFIG ortam değişkenine atayabilirsiniz.
# Böylece kubectl get nodes komutu
# doğru şekilde çalışacaktır.

#MODULES
#Burası üst kısımda kubeconfig dosyasını
#oluşturduktan sonra modüllerin kurulumu
#çağırır
module "traefik" {
  source     = "./modules/traefik"
  depends_on = [null_resource.get_kubeconfig]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  providers = {
    kubectl    = kubectl
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.traefik]
}


