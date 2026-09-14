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

  http_content = {
    "/user-data" = templatefile("http/user-data", {
      packer_password_hash = var.packer_password_hash
      packer_public_key    = trimspace(file("packer_ed25519.pub"))
    })

    "/meta-data" = ""
  }

  boot_command = [
    "<wait5>",
    "c",
    "<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>",
    "<wait5>",
    "initrd /casper/initrd",
    "<enter>",
    "<wait5>",
    "boot",
    "<enter>"
  ]

  ssh_username            = "packer"
  ssh_private_key_file    = abspath("packer_ed25519")
  ssh_handshake_attempts  = 3
  pause_before_connecting = "20s"

  shutdown_command = "sudo shutdown -P now"
  shutdown_timeout = "10m"

  iso_paths = [
    "[datastore1] ubuntu-24.04.3-live-server-amd64.iso"
  ]
}

build {
  sources = [
    "source.vsphere-iso.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo cloud-init clean --logs || true",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo sync"
    ]
  }
}
