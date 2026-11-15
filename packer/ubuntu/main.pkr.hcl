packer {
  required_plugins {
    vsphere = {
      source  = "github.com/vmware/vsphere"
      version = "2.5.0"
    }
  }
}

source "vsphere-iso" "ubuntu" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = true

  datacenter = "DataHoteling-DCDatacenter"
  host       = var.host
  datastore  = var.datastore

  vm_name = var.vm_name

  convert_to_template = true

  CPUs = var.num_cpus
  RAM  = var.memory

  guest_os_type = "ubuntu64Guest"

  storage {
    disk_size             = var.disk_size_mb
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }

  cd_label   = "cidata"
  cdrom_type = "ide"

  cd_content = {
    "user-data" = templatefile("nocloud/user-data.tmpl", {
      packer_username        = var.packer_username
      packer_password_hash   = var.packer_password_hash
      packer_public_key      = file(var.packer_public_key_file)
      provisioner_public_key = file(var.provisioner_public_key_file)
    })

    "meta-data" = file("nocloud/meta-data")
  }

  remove_cdrom = true

  boot_command = [
    "<wait15>",
    "c",
    "<wait2>",
    "linux /casper/vmlinuz autoinstall ip=dhcp ds=nocloud ---",
    "<enter>",
    "<wait5>",
    "initrd /casper/initrd",
    "<enter>",
    "<wait5>",
    "boot",
    "<enter>"
  ]

  communicator = "ssh"


  ssh_username         = var.packer_username
  ssh_private_key_file = var.ssh_private_key_file

  ssh_timeout            = "20m"
  ssh_handshake_attempts = 30

  ip_wait_timeout   = "15m"
  ip_settle_timeout = "10s"

  shutdown_timeout = "15m"

  iso_paths = [
    "[datastore1] ubuntu-22.04.5-live-server-amd64.iso"
  ]
}

build {
  sources = [
    "source.vsphere-iso.ubuntu"
  ]
}
