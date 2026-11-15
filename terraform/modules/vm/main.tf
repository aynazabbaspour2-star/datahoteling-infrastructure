resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  datastore_id     = var.datastore_id
  host_system_id   = var.host_system_id
  resource_pool_id = var.resource_pool_id

  num_cpus = var.num_cpus
  memory   = var.memory

  guest_id  = var.guest_id
  scsi_type = var.scsi_type

  poweron_timeout = 300

  wait_for_guest_ip_timeout   = 600
  wait_for_guest_net_timeout  = 600
  wait_for_guest_net_routable = false


  network_interface {
    network_id   = var.network_id
    adapter_type = var.network_adapter_type
  }

  disk {
    label            = var.disk_label
    size             = var.disk_size_gb
    unit_number      = var.disk_unit_number
    controller_type  = var.disk_controller_type
    thin_provisioned = var.thin_provisioned
  }

  clone {
    template_uuid = var.template_uuid
  }

}
