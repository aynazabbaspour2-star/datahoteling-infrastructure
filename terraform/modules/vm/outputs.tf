output "vm_id" {
  description = "Managed object ID of the virtual machine"
  value       = vsphere_virtual_machine.this.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = vsphere_virtual_machine.this.name
}

output "vm_uuid" {
  description = "UUID of the virtual machine"
  value       = vsphere_virtual_machine.this.uuid
}

output "power_state" {
  description = "Current power state of the virtual machine"
  value       = vsphere_virtual_machine.this.power_state
}
