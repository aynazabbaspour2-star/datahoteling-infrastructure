output "virtual_switch_name" {
  description = "Name of the managed standard virtual switch"
  value       = vsphere_host_virtual_switch.this.name
}

output "port_group_name" {
  description = "Name of the managed port group"
  value       = vsphere_host_port_group.this.name
}

output "port_group_key" {
  description = "Managed port group key"
  value       = vsphere_host_port_group.this.key
}
