variable "vsphere_server" {
  description = "Hostname or IP of the vCenter server"
  type        = string
}

variable "vault_address" {
  description = "Full URL of the Vault server"
  type        = string
  default     = "https://vault.rscc.com:8200"
}

variable "datacenter_name" {
  description = "vSphere datacenter name as it appears in vCenter"
  type        = string
}

variable "cluster_name" {
  description = "Compute cluster name inside the datacenter"
  type        = string
}

variable "datastore_name" {
  description = "Datastore where the VM disk will be created"
  type        = string
}

variable "network_name" {
  description = "Port group or distributed switch the VM NIC attaches to"
  type        = string
}

variable "vm_name" {
  description = "VM display name in vCenter, also gonna be used as the hostname"
  type        = string
}

variable "vm_num_cpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM in MB"
  type        = number
  default     = 4096
}

variable "vm_guest_id" {
  description = "vSphere guest OS identifier, so this must match the template"
  type        = string
}

variable "network_adapter_type" {
  description = "VM NIC driver type"
  type        = string
  default     = "vmxnet3"
}

variable "disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 20
}

variable "template_uuid" {
  description = "Managed object UUID of the Packer-built template to clone"
  type        = string
}

variable "domain" {
  description = "DNS domain appended to the VM hostname during guest customization"
  type        = string
  default     = "rscc.internal"
}
