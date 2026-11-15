output "vm_id" {
  description = "Managed object ID of the created virtual machine"
  value       = module.vm.vm_id
}

output "vm_uuid" {
  description = "UUID of the created virtual machine"
  value       = module.vm.vm_uuid
}

output "vm_name" {
  description = "Name of the created virtual machine"
  value       = module.vm.vm_name
}

output "power_state" {
  description = "Current power state of the virtual machine"
  value       = module.vm.power_state
}


output "vm_ip" {
  description = "Detected guest IP address of the Terraform-managed VM"
  value       = module.vm.default_ip_address
}
