variable "vsphere_server" {
  type = string
}

variable "vsphere_username" {
  type = string
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "host" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "num_cpus" {
  type    = number
  default = 2
}

variable "memory" {
  type    = number
  default = 2048
}

variable "disk_size_mb" {
  type    = number
  default = 20480
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "packer_password_hash" {
  type      = string
  sensitive = true
}
