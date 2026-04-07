# Packer — Ubuntu 22.04 LTS (Jammy) vSphere template
# packer build -var-file=vars/ubuntu-vars.pkr.hcl -var="vcenter_password=$VSPHERE_PASSWORD" templates/ubuntu.pkr.hcl

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
  template_name   = "ubuntu2204-template"
  iso_path        = "[${var.datastore}] iso/ubuntu-22.04.4-live-server-amd64.iso"
  build_timestamp = formatdate("YYYY-MM-DD", timestamp())
}

source "vsphere-iso" "ubuntu22" {
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
  notes               = "Ubuntu 22.04 LTS (Jammy) | Packer ${local.build_timestamp} | clone only"

  guest_os_type   = "ubuntu64Guest"
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
  http_directory = "http/ubuntu"

  # 15s — live-server loads the casper environment before GRUB hands off, slower than netinst
  boot_wait = "15s"

  # GRUB2 boot sequence: 'e' edits the selected entry, <f10> boots it
  # <esc> drops to a GRUB command line — wrong approach for this ISO
  boot_command = [
    "<wait3>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/ ip=dhcp ---<wait>",
    "<f10>"
  ]

  communicator     = "ssh"
  ssh_username     = "packer"
  ssh_password     = "packer"
  ssh_timeout      = "30m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
}

build {
  name    = "ubuntu22-vsphere"
  sources = ["source.vsphere-iso.ubuntu22"]

  provisioner "shell" {
    script          = "scripts/ubuntu.sh"
    execute_command = "echo 'packer' | sudo -S bash '{{.Path}}'"
  }

  post-processor "manifest" {
    output     = "builds/ubuntu22-manifest.json"
    strip_path = true
  }
}
