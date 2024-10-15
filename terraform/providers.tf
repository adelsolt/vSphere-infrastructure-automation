provider "vsphere" {
  user           = var.vsphere_user       # Username is now securely stored in Vault
  password       = var.vsphere_password   # Password is securely stored in Vault
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

provider "vault" {
  address = "https://vault.example.com:8200"  # Vault server address
}

data "vault_generic_secret" "vsphere_creds" {
  path = "secret/data/vsphere"  # Vault path for vSphere credentials
}

provider "ansible" {
  user        = data.vault_generic_secret.ansible_creds.data["user"]  # Ansible credentials from Vault
  private_key = data.vault_generic_secret.ansible_creds.data["private_key"]
}

