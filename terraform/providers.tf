terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.6"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20"
    }
  }
}

provider "vault" {
  address = var.vault_address
  # VAULT_TOKEN env var is picked up automatically 
}

data "vault_generic_secret" "vsphere_creds" {
  path = "secret/vsphere"
}

provider "vsphere" {
  user                 = data.vault_generic_secret.vsphere_creds.data["user"]
  password             = data.vault_generic_secret.vsphere_creds.data["password"]
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true # this is just for testing, in prod we have to set to false with a vCenter valid cert
}
