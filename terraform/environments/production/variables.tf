variable "datacenter_name" {
  description = "vSphere datacenter"
  type        = string
  default     = "DataHoteling-DCDatacenter"
}

variable "esxi_host" {
  description = "ESXi host"
  type        = string
}

variable "datastore_name" {
  description = "Datastore for VPS VMs"
  type        = string
  default     = "datastore1"
}

variable "network_name" {
  description = "Existing vSphere network/port group"
  type        = string
  default     = "VM Network"
}

variable "template_uuid" {
  description = "Golden Ubuntu template UUID"
  type        = string
}

variable "vm_name" {
  description = "Name of the VPS VM"
  type        = string
  default     = "DH-VPS-TEST-01"
}

variable "num_cpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "scsi_type" {
  description = "SCSI controller type"
  type        = string
  default     = "lsilogic"

  validation {
    condition     = contains(["lsilogic", "lsilogic-sas", "pvscsi"], var.scsi_type)
    error_message = "scsi_type must be one of: lsilogic, lsilogic-sas, pvscsi."
  }
}

variable "network_adapter_type" {
  description = "VM network adapter type"
  type        = string
  default     = "vmxnet3"
}
