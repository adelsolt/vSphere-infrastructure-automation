# Variables definition for Terraform

variable "vcenter_user" {
  description = "vCenter username"
  type        = string
}

variable "vcenter_password" {
  description = "vCenter password"
  type        = string
}

variable "vcenter_server" {
  description = "vCenter server address"
  type        = string
}

variable "datacenter_name" {
  description = "Name of the datacenter"
  type        = string
}

variable "cluster_name" {
  description = "Name of the compute cluster"
  type        = string
}

variable "datastore_name" {
  description = "Name of the datastore"
  type        = string
}

variable "network_name" {
  description = "Name of the network"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_num_cpus" {
  description = "Number of CPUs for the VM"
  type        = number
}

variable "vm_memory" {
  description = "Amount of memory for the VM (in MB)"
  type        = number
}

variable "vm_guest_id" {
  description = "Guest OS ID for the VM"
  type        = string
}

variable "network_adapter_type" {
  description = "Network adapter type"
  type        = string
}

variable "disk_size" {
  description = "Size of the disk (in GB)"
  type        = number
}

variable "template_uuid" {
  description = "UUID of the VM template"
  type        = string
}

variable "domain" {
  description = "Domain name for the VM"
  type        = string
}
