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

  datacenter = "DataHoteling-DCDatacenter"
  host       = var.host
  datastore  = var.datastore

  vm_name = var.vm_name

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
      packer_password_b64 = base64encode(var.ssh_password)
      packer_public_key   = trimspace(file("packer_ed25519.pub"))
    })
  }

  boot_command = [
    "<wait5>",
    "<tab>",
    " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg",
    "<enter>",
    "<wait5>"
  ]

  ssh_username = "packer"
  ssh_private_key_file = abspath("packer_ed25519")

  ssh_handshake_attempts = 3
  pause_before_connecting = "20s"

  shutdown_command = "sudo shutdown -P now"
  shutdown_timeout = "10m"

  iso_paths = [
    "[datastore1] AlmaLinux-9.7-x86_64-minimal.iso"
  ]
}

build {
  sources = [
    "source.vsphere-iso.almalinux"
  ]

  provisioner "shell" {
    inline = [
      "sudo rm -f /home/packer/.ssh/authorized_keys",
      "sudo userdel -r packer || true",
      "sudo cloud-init clean --logs || true",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /etc/ssh/ssh_host_*",
      "sudo sync"
    ]
  }
}
