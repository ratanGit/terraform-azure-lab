
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

###########################################################
# 1. LOCAL PREP: Render the .env file from the .tpl
# This stays on your laptop in the "guacamole" folder
###########################################################
resource "local_file" "guacamole_env" {
  content = templatefile("${path.module}/.env.tpl", {
    base_path          = "/home/${var.linux_vm_admin_username}/guacamole"
    guac_db_password   = var.guac_db_password
    npm_db_password    = var.npm_db_password
    guacamole_dns_name = azurerm_public_ip.guacamole.ip_address
    guac_db_user       = "guacamole_user"
    guac_db_name       = "guacamole_db"
  })
  filename = "${path.module}/guacamole/.env"
}

############################################
# Virtual Network (The Foundation)
############################################

resource "azurerm_virtual_network" "this" {
  # Convention: lab-vnet
  name                = "${local.name_prefix}-vnet"
  address_space       = var.vnet_cidr["Lab"].address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name


  tags = local.common_tags
}

############################################
# Subnets (Public + Private)
############################################

resource "azurerm_subnet" "this" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]
}
