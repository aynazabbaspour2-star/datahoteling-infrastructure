data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_host" "host" {
  name          = var.esxi_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "root" {
  name = "Resources"
}

module "network" {
  source = "../../modules/network"

  host_system_id      = data.vsphere_host.host.id
  virtual_switch_name = var.virtual_switch_name
  network_name        = var.network_name
  network_vlan_id     = var.network_vlan_id

  uplink_nics  = var.uplink_nics
  active_nics  = var.active_nics
  standby_nics = var.standby_nics
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

output "resource_pool_id" {
  description = "Production root resource pool ID"
  value       = data.vsphere_resource_pool.root.id
}

output "managed_virtual_switch" {
  description = "Terraform-managed production virtual switch"
  value       = module.network.virtual_switch_name
}

output "managed_network_name" {
  description = "Terraform-managed production port group"
  value       = module.network.port_group_name
}
