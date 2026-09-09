data "vsphere_resource_pool" "root" {
  name = "Resources"
}

output "resource_pool_id" {
  value = data.vsphere_resource_pool.root.id
}
