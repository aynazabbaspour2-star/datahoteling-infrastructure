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
  description = "Name of the temporary VM used to build the golden image"
  default     = "datahoteling-almalinux-template"
}

variable "num_cpus" {
  type        = number
  description = "CPU count for the temporary Packer build VM"
  default     = 2
}

variable "memory" {
  type        = number
  description = "Memory in MB for the temporary Packer build VM"
  default     = 4096
}

variable "host" {
  type        = string
  description = "ESXi host used by Packer during image creation"
}

variable "datastore" {
  type        = string
  description = "Datastore used by Packer during image creation"
}

variable "network" {
  type        = string
  description = "Temporary build network used by Packer"
}

variable "disk_size_mb" {
  type        = number
  description = "Disk size in MB for the temporary Packer build VM"
  default     = 20480
}

variable "ssh_password" {
  type        = string
  description = "Temporary SSH password used during image provisioning"
  sensitive   = true
}

variable "iso_url" {
  type        = string
  description = "AlmaLinux ISO URL"
  default     = "https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9-latest-x86_64-dvd.iso"
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum of the AlmaLinux ISO"
  default     = "7a392bdc879afd159b30da39a356b7b26c1ddf618b01549164da9aadbc40d814"
}
