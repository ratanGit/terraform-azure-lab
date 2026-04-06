resource "azurerm_subnet" "public" {
  for_each = local.public_subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]
}
