resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  address_space       = [var.vnet_cidr]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}