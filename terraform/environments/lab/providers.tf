terraform {
  required_version = ">= 1.16.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.16.1"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}
