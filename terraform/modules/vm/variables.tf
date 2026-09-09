variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}

variable "datastore_id" {
  description = "vSphere datastore ID"
  type        = string
}

variable "host_system_id" {
  description = "vSphere host system ID"
  type        = string
}

variable "resource_pool_id" {
  description = "vSphere resource pool ID"
  type        = string
}

variable "network_id" {
  description = "vSphere network ID"
  type        = string
}

variable "num_cpus" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "guest_id" {
  description = "VMware guest OS identifier"
  type        = string
}

variable "disk_size_gb" {
  description = "Virtual disk size in GB"
  type        = number
  default     = 150
}

variable "disk_label" {
  description = "Virtual disk label"
  type        = string
  default     = "disk0"
}

variable "disk_unit_number" {
  description = "Virtual disk unit number"
  type        = number
  default     = 0
}

variable "disk_controller_type" {
  description = "Virtual disk controller type"
  type        = string
  default     = "scsi"
}

variable "thin_provisioned" {
  description = "Whether the virtual disk is thin provisioned"
  type        = bool
  default     = true
}

variable "network_adapter_type" {
  description = "Virtual network adapter type"
  type        = string
  default     = "vmxnet3"
}
