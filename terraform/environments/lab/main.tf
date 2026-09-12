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

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "vm" {
  source = "../../modules/vm"

  vm_name          = var.vm_name
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.host.id
  resource_pool_id = var.resource_pool_id

  network_id = data.vsphere_network.network.id

  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = var.guest_id

  disk_size_gb         = var.disk_size_gb
  disk_label           = var.disk_label
  disk_unit_number     = var.disk_unit_number
  disk_controller_type = var.disk_controller_type
  thin_provisioned     = var.thin_provisioned
  network_adapter_type = var.network_adapter_type
}
