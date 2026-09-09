variable "vsphere_server" {
  type        = string
  description = "vSphere / ESXi server address"
}

variable "vsphere_username" {
  type        = string
  description = "vSphere / ESXi username"
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "vSphere / ESXi password"
  sensitive   = true
}

variable "vm_name" {
  type        = string
  description = "Name of the Packer-built VM"
  default     = "datahoteling-almalinux-template"
}

variable "ssh_password" {
  type        = string
  description = "Temporary SSH password used during image provisioning"
  sensitive   = true
}
