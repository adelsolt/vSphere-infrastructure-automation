# Packer — CentOS Stream 9 vSphere template
# packer build -var-file=vars/centos-vars.pkr.hcl -var="vcenter_password=$VSPHERE_PASSWORD" templates/centos.pkr.hcl

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
  template_name   = "centos9-template"
  iso_path        = "[${var.datastore}] iso/CentOS-Stream-9-latest-x86_64-dvd1.iso"
  build_timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "vsphere-iso" "centos9" {
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
  notes               = "CentOS Stream 9 | Packer ${local.build_timestamp} | clone only"

  guest_os_type   = "rhel9_64Guest"
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
  http_directory = "http/centos"

  # 15s — EFI firmware init on vSphere virtual hardware adds a few seconds vs BIOS
  boot_wait = "15s"

  # CentOS Stream 9 is GRUB2 — <tab> to edit the boot line is CentOS 7 only
  # 'e' enters edit mode, <ctrl-x> boots the modified entry
  boot_command = [
    "<wait3>",
    "e<wait>",
    "<down><down><end>",
    " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/centos-ks.cfg inst.text biosdevname=0 net.ifnames=0<wait>",
    "<ctrl-x>"
  ]

  communicator     = "ssh"
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "centos9-vsphere"
  sources = ["source.vsphere-iso.centos9"]

  provisioner "shell" {
    script          = "scripts/centos.sh"
    execute_command = "echo 'packer' | sudo -S bash '{{.Path}}'"
  }

  post-processor "manifest" {
    output     = "builds/centos9-manifest.json"
    strip_path = true
  }
}
