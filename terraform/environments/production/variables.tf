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
  default     = "datastore1"
}

variable "virtual_switch_name" {
  description = "Terraform-managed standard vSwitch name"
  type        = string
}

variable "network_name" {
  description = "Terraform-managed production port group name"
  type        = string
}

variable "network_vlan_id" {
  description = "VLAN ID. Use 0 for an untagged network."
  type        = number
  default     = 0

  validation {
    condition     = var.network_vlan_id >= 0 && var.network_vlan_id <= 4094
    error_message = "VLAN ID must be between 0 and 4094."
  }
}

variable "uplink_nics" {
  description = "Physical ESXi vmnic uplinks for the managed vSwitch"
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
