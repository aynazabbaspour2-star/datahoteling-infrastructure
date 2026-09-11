packer {
  required_plugins {
    vsphere = {
      source  = "github.com/vmware/vsphere"
      version = "2.5.0"
    }
  }
}

source "vsphere-iso" "almalinux" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_username
  password            = var.vsphere_password
  insecure_connection = true

  host      = var.host
  datastore = var.datastore

  vm_name = var.vm_name

  # Convert the completed AlmaLinux VM into a reusable vSphere template.
  convert_to_template = true

  CPUs = var.num_cpus
  RAM  = var.memory

  guest_os_type = "rhel9_64Guest"

  storage {
    disk_size             = var.disk_size_mb
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.network
    network_card = "vmxnet3"
  }


  http_content = {
    "/ks.cfg" = templatefile("http/ks.cfg", {
      packer_password = var.ssh_password
    })
  }

  boot_command = [
    "<wait5>",
    "e",
    "<wait1>",
    "<down><down><down><down><end>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter>",
    "<wait5>"
  ]

  ssh_username = "packer"
  ssh_password = var.ssh_password

  iso_url      = var.iso_url
  iso_checksum = "sha256:${var.iso_checksum}"
}

build {
  sources = [
    "source.vsphere-iso.almalinux"
  ]
}
