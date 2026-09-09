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

  host      = "192.168.1.21"
  datastore = "datastore1"

  vm_name = var.vm_name

  CPUs = 2
  RAM  = 4096

  guest_os_type = "rhel9_64Guest"

  storage {
    disk_size             = 20480
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }

  http_directory = "http"

  http_content = {
    "/ks.cfg" = templatefile("${path.root}/http/ks.cfg", {
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

  iso_url      = "https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9-latest-x86_64-dvd.iso"
  iso_checksum = "sha256:7a392bdc879afd159b30da39a356b7b26c1ddf618b01549164da9aadbc40d814"
}

build {
  sources = [
    "source.vsphere-iso.almalinux"
  ]
}
