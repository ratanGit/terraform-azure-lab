###############################################################################
# OUTPUTS - PROJECT: Guacamole
#
# DESIGN PRINCIPLES:
# - `foundation` is the ONLY stable contract for downstream Terraform usage
# - `information` and `key_features` are human-readable summaries
# - `access_information` is for local / operational use only
###############################################################################

############################################
# FOUNDATION OUTPUTS (FOR REUSE)
############################################

output "foundation" {
  description = "Stable infrastructure primitives intended for reuse by other Terraform projects"

  value = {
    resource_group = {
      name = azurerm_resource_group.this.name
      id   = azurerm_resource_group.this.id
    }

    location    = var.location
    environment = var.environment
    project     = var.project

    virtual_network = {
      id            = azurerm_virtual_network.this.id
      name          = azurerm_virtual_network.this.name
      address_space = azurerm_virtual_network.this.address_space
    }

    subnets = {
      for k, s in azurerm_subnet.this :
      k => {
        id             = s.id
        name           = s.name
        address_prefix = s.address_prefixes
      }
    }

    tags = local.common_tags
  }
}

############################################
# INFORMATION (HUMAN-READABLE SUMMARY)
############################################

output "information" {
  description = "High-level, human-readable summary of the deployed environment (not for downstream Terraform consumption)"

  value = {
    project        = var.project
    environment    = var.environment
    location       = var.location
    resource_group = azurerm_resource_group.this.name

    networking = {
      vnet_name    = azurerm_virtual_network.this.name
      subnet_names = keys(azurerm_subnet.this)
    }
  }
}

############################################
# KEY FEATURES (DOCUMENTATION)
############################################

output "key_features" {
  description = "Key infrastructure components deployed in this environment (descriptive only)"

  value = {
    guacamole_gateway = {
      purpose = "Remote access gateway providing web-based SSH/RDP via Apache Guacamole"
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
# ACCESS INFORMATION (OPERATIONAL / LOCAL USE)
# NOT INTENDED FOR DOWNSTREAM TERRAFORM CONSUMPTION
############################################

output "access_information" {
  description = "Operational access endpoints and helper SSH commands for administrators"

  value = {
    guacamole = {
      public_ip    = azurerm_public_ip.guacamole.ip_address
      ssh_user     = var.linux_vm_admin_username
      ssh_key_path = local_file.guacamole_private_key.filename
      https_url    = "https://${azurerm_public_ip.guacamole.ip_address}"
      ssh_command  = "ssh -i ${local_file.guacamole_private_key.filename} ${var.linux_vm_admin_username}@${azurerm_public_ip.guacamole.ip_address}"
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
