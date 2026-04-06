
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

variable "my_ip" {
  description = "Your public IP address in CIDR notation"
  type        = string
}

############################################
# VM / SSH settings
############################################

variable "vm_admin_username" {
  description = "Admin username for Linux VMs"
  type        = string
}

variable "vm_ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}