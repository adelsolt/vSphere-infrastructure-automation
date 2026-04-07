# Packer — Debian 12 (Bookworm) vSphere template
# packer init templates/debian.pkr.hcl
# packer build -var-file=vars/debian-12-vars.pkr.hcl -var="vcenter_password=$VSPHERE_PASSWORD" templates/debian.pkr.hcl

packer {
  required_version = ">= 1.9.0"
  required_plugins {
    vsphere = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

variable "vcenter_server" { type = string }
variable "vcenter_user"   { type = string }
variable "vcenter_password" {
  type      = string
  sensitive = true
}
variable "datacenter" { type = string }
variable "cluster"    { type = string }
variable "datastore"  { type = string }
variable "network"    { type = string }

locals {
  template_name   = "debian12-template"
  iso_path        = "[${var.datastore}] iso/debian-12.7.0-amd64-netinst.iso"
  build_timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "vsphere-iso" "debian12" {
  vcenter_server      = var.vcenter_server
  username            = var.vcenter_user
  password            = var.vcenter_password
  datacenter          = var.datacenter
  cluster             = var.cluster
  datastore           = var.datastore
  insecure_connection = true

  vm_name             = "${local.template_name}-${local.build_timestamp}"
  folder              = "Templates"
  convert_to_template = true
  notes               = "Debian 12 (Bookworm) | Packer ${local.build_timestamp} | clone only"

  guest_os_type   = "debian11_64Guest" # vSphere has no debian12 guest ID yet
  CPUs            = 2
  RAM             = 2048
  RAM_reserve_all = false

  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  iso_paths      = [local.iso_path]
  http_directory = "http/debian"

  # 12s floor — vSphere needs time to POST and render the GRUB menu before keystrokes land
  boot_wait = "12s"
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{.HTTPIP}}:{{.HTTPPort}}/debian-12-preseed.cfg ",
    "hostname=${local.template_name} ",
    "debian-installer=en_US locale=en_US.UTF-8 ",
    "kbd-chooser/method=us keyboard-configuration/xkb-keymap=us ",
    "fb=false debconf/frontend=noninteractive<enter>"
  ]

  communicator     = "ssh"
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "debian12-vsphere"
  sources = ["source.vsphere-iso.debian12"]

  provisioner "shell" {
    script          = "scripts/debian.sh"
    execute_command = "echo 'packer' | sudo -S bash '{{.Path}}'"
  }

  post-processor "manifest" {
    output     = "builds/debian12-manifest.json"
    strip_path = true
  }
}
