data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm_network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.vm_num_cpus
  memory   = var.vm_memory
  guest_id = var.vm_guest_id

  network_interface {
    network_id   = data.vsphere_network.vm_network.id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = true
    eagerly_scrub    = false
  }

  clone {
    template_uuid = var.template_uuid

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = var.domain
      }
      # network_interface block omitted, defaults to DHCP
      # or could just add ipv4_address / ipv4_netmask / ipv4_gateway here for static assignment
    }
  }
  wait_for_guest_net_timeout = 5
}
