variable "vcenter_server" {
  type    = string
  default = "your_vcenter_ip"    # Replace with your vCenter server IP
}

variable "vcenter_user" {
  type    = string
  default = "administrator@vsphere.local"  # Replace with your vSphere admin username
}

variable "vcenter_password" {
  type    = string
  default = "password"             # Replace with your vSphere password
}

variable "datastore" {
  type    = string
  default = "datastore1"           # Replace with your datastore name
}

variable "network" {
  type    = string
  default = "VM Network"           # Replace with your network name
}

variable "cluster" {
  type    = string
  default = "Cluster1"             # Replace with your cluster name
}

variable "datacenter" {
  type    = string
  default = "Datacenter1"          # Replace with your datacenter name
}
