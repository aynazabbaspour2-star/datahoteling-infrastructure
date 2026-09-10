variable "datacenter_name" {
  description = "vSphere datacenter name"
  type        = string
  default     = "ha-datacenter"
}

variable "esxi_host" {
  description = "ESXi host address or hostname"
  type        = string
}

variable "datastore_name" {
  description = "vSphere datastore name"
  type        = string
}

variable "resource_pool_id" {
  description = "vSphere resource pool ID"
  type        = string
}

variable "vm_name" {
  description = "Lab VM name"
  type        = string
}

variable "num_cpus" {
  description = "Number of virtual CPUs"
  type        = number
}

variable "memory" {
  description = "Memory allocated to the VM in MB"
  type        = number
}

variable "guest_id" {
  description = "VMware guest OS identifier"
  type        = string
}

variable "disk_size_gb" {
  description = "Virtual disk size in GB"
  type        = number
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

variable "virtual_switch_name" {
  description = "Terraform-managed standard vSwitch name"
  type        = string
}

variable "network_name" {
  description = "Terraform-managed port group name"
  type        = string
}

variable "network_vlan_id" {
  description = "VLAN ID. Use 0 for an untagged network."
  type        = number
  default     = 0
}

variable "uplink_nics" {
  description = "Physical ESXi vmnic uplinks"
  type        = list(string)
  default     = []
}

variable "active_nics" {
  description = "Active ESXi uplinks"
  type        = list(string)
  default     = []
}

variable "standby_nics" {
  description = "Standby ESXi uplinks"
  type        = list(string)
  default     = []
}
