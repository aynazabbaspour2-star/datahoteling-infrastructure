variable "vsphere_server" {
  description = "vSphere / ESXi API endpoint"
  type        = string
}

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}
