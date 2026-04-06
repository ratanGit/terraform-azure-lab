
variable "resource_group_name" {
  description = "Name of an existing Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for the VNet"
  type        = string
}

variable "subnets" {
  description = "Subnet definitions"
  type = map(object({
    cidr = string
    type = string # public or private
  }))
}
