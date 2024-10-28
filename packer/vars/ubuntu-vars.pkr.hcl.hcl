variable "vcenter_server" {
  type    = string
  default = "your_vcenter_ip"    # vCenter server IP
}

variable "vcenter_user" {
  type    = string
  default = "administrator@vsphere.local"  # vSphere admin username
}

variable "vcenter_password" {
  type    = string
  default = "password"             # vSphere password
}

variable "datastore" {
  type    = string
  default = "datastore1"           # datastore name
}

variable "network" {
  type    = string
  default = "VM Network"           # network name
}

variable "cluster" {
  type    = string
  default = "Cluster1"             # cluster name
}

variable "datacenter" {
  type    = string
  default = "Datacenter1"          # datacenter name
}
"
