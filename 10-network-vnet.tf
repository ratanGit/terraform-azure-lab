############################################
# Virtual Network (The Foundation)
############################################

resource "azurerm_virtual_network" "this" {
  # Convention: lab-vnet
  name                = "${local.name_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  tags = local.common_tags
}