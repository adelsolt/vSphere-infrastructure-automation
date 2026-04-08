output "vm_id" {
  description = "vSphere managed object ID of the VM"
  value       = vsphere_virtual_machine.vm.id
}

output "vm_default_ip" {
  description = "Primary IP address — populated once VMware Tools reports it"
  value       = vsphere_virtual_machine.vm.default_ip_address
}

output "vm_name" {
  description = "VM display name in vCenter"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_guest_id" {
  description = "Guest OS identifier set on the VM"
  value       = vsphere_virtual_machine.vm.guest_id
}
