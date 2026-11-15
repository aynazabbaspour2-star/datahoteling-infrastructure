data "vsphere_resource_pool" "root" {
  name          = "${var.esxi_host}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

output "resource_pool_id" {
  value = data.vsphere_resource_pool.root.id
}
