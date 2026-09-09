variable "vm_name" {
  description = "Name of the lab virtual machine"
  type        = string
  default     = "datahoteling-lab-vm"
}

variable "resource_pool_id" {
  description = "vSphere resource pool ID for the lab VM"
  type        = string
}

variable "num_cpus" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "guest_id" {
  description = "VMware guest OS identifier"
  type        = string
}

variable "disk_size_gb" {
  description = "Lab VM disk size in GB"
  type        = number
  default     = 20
}

variable "disk_label" {
  description = "Lab VM disk label"
  type        = string
  default     = "disk0"
}

variable "disk_unit_number" {
  description = "Lab VM disk unit number"
  type        = number
  default     = 0
}

variable "disk_controller_type" {
  description = "Lab VM disk controller type"
  type        = string
  default     = "scsi"
}

variable "thin_provisioned" {
  description = "Whether the lab VM disk is thin provisioned"
  type        = bool
  default     = true
}

variable "network_adapter_type" {
  description = "Lab VM network adapter type"
  type        = string
  default     = "vmxnet3"
}
