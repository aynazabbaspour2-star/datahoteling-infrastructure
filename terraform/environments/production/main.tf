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
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "vm" {
  source = "../../modules/vm"

  vm_name          = var.vm_name
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = data.vsphere_resource_pool.root.id

  num_cpus = var.num_cpus
  memory   = var.memory_mb

  guest_id  = "ubuntu64Guest"
  scsi_type = var.scsi_type

  network_id           = data.vsphere_network.network.id
  network_adapter_type = var.network_adapter_type

  disk_label           = "disk0"
  disk_size_gb         = var.disk_size_gb
  disk_unit_number     = 0
  disk_controller_type = "scsi"
  thin_provisioned     = true

  template_uuid = var.template_uuid
}

output "datacenter_name" {
  value = data.vsphere_datacenter.dc.name
}

output "host_name" {
  value = data.vsphere_host.host.name
}

output "datastore_name" {
  value = data.vsphere_datastore.datastore.name
}

output "resource_pool_id" {
  value = data.vsphere_resource_pool.root.id
}

output "network_name" {
  value = data.vsphere_network.network.name
}

output "network_id" {
  value = data.vsphere_network.network.id
}

output "vm_ip" {
  description = "Detected guest IP address"
  value       = module.vm.default_ip_address
}
