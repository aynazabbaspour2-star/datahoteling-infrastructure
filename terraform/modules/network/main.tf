resource "vsphere_host_virtual_switch" "this" {
  name           = var.virtual_switch_name
  host_system_id = var.host_system_id

  network_adapters = var.uplink_nics

  active_nics  = var.active_nics
  standby_nics = var.standby_nics
}

resource "vsphere_host_port_group" "this" {
  name                = var.network_name
  host_system_id      = var.host_system_id
  virtual_switch_name = vsphere_host_virtual_switch.this.name
  vlan_id             = var.network_vlan_id
}
