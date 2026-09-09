data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

data "vsphere_host" "host" {
  name          = "192.168.1.21"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vm_network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "root" {
  name = "Resources"
}

output "datacenter_name" {
  description = "Production vSphere datacenter"
  value       = data.vsphere_datacenter.dc.name
}

output "host_name" {
  description = "Production ESXi host"
  value       = data.vsphere_host.host.name
}

output "datastore_name" {
  description = "Production datastore"
  value       = data.vsphere_datastore.datastore.name
}

output "network_name" {
  description = "Production VM network"
  value       = data.vsphere_network.vm_network.name
}

output "resource_pool_id" {
  description = "Production root resource pool ID"
  value       = data.vsphere_resource_pool.root.id
}
