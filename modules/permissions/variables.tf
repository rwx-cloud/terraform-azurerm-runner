variable "name_suffix" {
  description = "Unique suffix for the provisioning and subnet custom role names."
  type        = string
}

variable "resource_group_id" {
  description = "ARM ID of the dedicated runner resource group."
  type        = string
}

variable "subnet_id" {
  description = "ARM ID of the only subnet the provisioner can join."
  type        = string
}

variable "principal_id" {
  description = "Object ID of the provisioning identity."
  type        = string
}
