###############################################################################
# OUTPUTS - PROJECT: Guacamole
# Logical Sections: Information, Key Features, Access Information
###############################################################################

############################################
# INFORMATION
############################################

output "information" {
  description = "High-level infrastructure information"
  value = {
    resource_group = azurerm_resource_group.this.name
    location       = var.location
    environment    = var.environment
    project        = var.project
    vnet_id        = azurerm_virtual_network.this.id
    subnet_ids = {
      for k, s in azurerm_subnet.this :
      k => s.id
    }
  }
}

############################################
# KEY FEATURES
############################################

output "key_features" {
  description = "Key infrastructure components deployed in this environment"
  value = {
    guacamole_gateway = {
      purpose = "Remote access gateway (Web-based SSH/RDP via Guacamole)"
      network = "Public subnet"
    }

    linux_router = {
      purpose = "Linux-based NAT router replacing Azure NAT Gateway"
      network = "Public (WAN) + Private (LAN)"
    }

    internal_linux_vm = {
      purpose = "Private internal Linux workload VM"
      network = "Private subnet only"
    }
  }
}

############################################
# ACCESS INFORMATION
############################################

output "access_information" {
  description = "Access endpoints and SSH commands for all major components"

  value = {
    guacamole = {
      public_ip      = azurerm_public_ip.guacamole.ip_address
      ssh_user       = var.linux_vm_admin_username
      ssh_key_path   = local_file.guacamole_private_key.filename
      https_url      = "https://${azurerm_public_ip.guacamole.ip_address}"
      ssh_command    = "ssh -i ${local_file.guacamole_private_key.filename} ${var.linux_vm_admin_username}@${azurerm_public_ip.guacamole.ip_address}"
    }

    router = {
      public_ip    = azurerm_public_ip.router.ip_address
      ssh_user     = var.linux_vm_admin_username
      ssh_key_path = local_file.guacamole_private_key.filename
      ssh_command  = "ssh -i ${local_file.guacamole_private_key.filename} ${var.linux_vm_admin_username}@${azurerm_public_ip.router.ip_address}"
    }

    private_linux_vm = {
      private_ip   = azurerm_network_interface.private_linux.private_ip_address
      ssh_user     = var.linux_vm_admin_username
      ssh_key_path = local_file.guacamole_private_key.filename
      ssh_command  = "ssh -i ${local_file.guacamole_private_key.filename} ${var.linux_vm_admin_username}@${azurerm_network_interface.private_linux.private_ip_address}"
    }
  }
}

############################################
# PROJECT TAGS
############################################

output "project_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}