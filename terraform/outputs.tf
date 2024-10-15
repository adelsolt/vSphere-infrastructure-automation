output "vm_ip" {
  description = "The VM's assigned IP address."
  value       = var.vm_ip
}

output "vm_name" {
  description = "The name of the deployed VM."
  value       = vsphere_virtual_machine.vm.name
}

output "datastore" {
  description = "The datastore used for the VM."
  value       = data.vsphere_datastore.datastore.name
}

output "network" {
  description = "The network used for the VM."
  value       = data.vsphere_network.network.name
}
