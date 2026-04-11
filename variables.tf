###############################################################################
# GLOBAL SETTINGS SCHEMA
###############################################################################

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
  default     = "rg-ratan-lab-canada"
}

variable "location" {
  type        = string
  description = "Azure region for deployment."
  default     = "canadacentral"
}

variable "my_ip" {
  type        = string
  description = "Your public IP (CIDR format e.g. 1.2.3.4/32) to allow access to Bastion/NVA."
}

variable "environment" {
  type        = string
  description = "Type of Deployment- lab or prod."
  default     = "lab"
}

variable "project" {
  type        = string
  description = "Project"
  default     = "guac"
}

variable "author" {
  type        = string
  description = "Who"
  default     = "Ratan Mohapatra"
}

############################################
# COMPUTE: ACCESS, 
############################################

#GUAC VM Settings

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

variable "ubuntu_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server" # This is the Gen2 SKU from your CLI list
    version   = "latest"
  }
}

variable "guac_vm_size" {
  description = "guac_vm_size"
  type        = string
  default     = "Standard_B2s"
}

# LINUX ROUTER to repalce the Nat GW
variable "linux_vm_size" {
  description = "Size of the Linux workload VM"
  type        = string
  default     = "Standard_B1ms"
}

variable "linux_vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "linux_vm_ssh_public_key" {
  description = "Path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/terraform_id_rsa.pub"
}


###############################################################################
# NETWORK TOPOLOGY
###############################################################################

variable "vnet_cidr" {
  type = map(object({
    address_space = list(string)
    subnets       = map(string)
  }))
  description = "Map defining VNets (Security, Production, Staging) and their Subnets."
}