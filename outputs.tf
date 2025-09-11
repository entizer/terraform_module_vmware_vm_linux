output "vm_ip" {
  description = "VM IP address"
  value       = vsphere_virtual_machine.vm.default_ip_address
}

output "vm_name" {
  description = "VM name"
  value       = vsphere_virtual_machine.vm.name
}

output "vm_uuid" {
  description = "VM UUID"
  value       = vsphere_virtual_machine.vm.uuid
}