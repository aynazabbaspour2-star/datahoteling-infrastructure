variable "datacenter_name" {
  description = "vSphere datacenter name"
  type        = string
  default     = "ha-datacenter"
}

variable "esxi_host" {
  description = "ESXi host name or address"
  type        = string
}

variable "datastore_name" {
  description = "vSphere datastore name"
  type        = string
  default     = "datastore1"
}

variable "network_name" {
  description = "Existing vSphere port group used by the lab VM"
  type        = string
  default     = "VM Network"
}

variable "vm_name" {
  description = "Name of the lab virtual machine"
  type        = string
  default     = "datahoteling-lab-vm"
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
  default     = "rhel9_64Guest"
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
  description = "Disk controller type"
  type        = string
  default     = "scsi"
}

variable "thin_provisioned" {
  description = "Whether the lab VM disk is thin provisioned"
  type        = bool
  default     = true
}

variable "network_adapter_type" {
  description = "Virtual network adapter type"
  type        = string
  default     = "vmxnet3"
}
