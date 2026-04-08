# SCHEMA ##########################

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
  default     = "ratan"
}

variable "vm_ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
  # Since you are using tls_private_key in your main code, 
  # you might not even need this variable.
  default     = "~/.ssh/id_rsa.pub" 
}

variable "vm_image_publisher" {
  type    = string
  default = "Canonical"
}

variable "vm_image_offer" {
  type    = string
  default = "ubuntu-24_04-lts" # This is the Gen2 image in eastus2
}

variable "vm_image_sku" {
  type    = string
  default = "server" # This is the Gen2 SKU from your CLI list
}

variable "vm_image_version" {
  type    = string
  default = "latest"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B2s"
}

############################################
# GUAC VM Settings
############################################

variable "guac_db_user" { 
  default = "guacamole_user"
}

variable "guac_db_name" {
  default = "guacamole_db"
}

variable "guac_db_password" {
  type        = string
  sensitive   = true
  description = "Password for the Guacamole PostgreSQL database"
}

variable "npm_db_password" {
  type        = string
  sensitive   = true
  description = "Password for the NPM database"
}

variable "guacamole_dns_name" {
  type        = string
  description = "The FQDN for your Guacamole instance"
}

variable "base_path" {
  type        = string
  default     = "."
  description = "Project root for Docker volumes"
}