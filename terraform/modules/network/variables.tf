variable "host_system_id" {
  description = "vSphere ESXi host system ID"
  type        = string
}

variable "virtual_switch_name" {
  description = "Name of the Terraform-managed vSphere standard virtual switch"
  type        = string
}

variable "network_name" {
  description = "Name of the Terraform-managed port group"
  type        = string
}

variable "network_vlan_id" {
  description = "VLAN ID for the port group. Use 0 for an untagged network."
  type        = number
  default     = 0

  validation {
    condition     = var.network_vlan_id >= 0 && var.network_vlan_id <= 4094
    error_message = "VLAN ID must be between 0 and 4094."
  }
}

variable "uplink_nics" {
  description = "Physical ESXi vmnic uplinks assigned to the standard virtual switch"
  type        = list(string)
  default     = []
}

variable "active_nics" {
  description = "Active uplinks for the standard virtual switch"
  type        = list(string)
  default     = []
}

variable "standby_nics" {
  description = "Standby uplinks for the standard virtual switch"
  type        = list(string)
  default     = []
}
