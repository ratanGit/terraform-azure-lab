resource "azurerm_network_security_group" "public" {
  name                = "${local.name_prefix}-nsg-public"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}
resource "azurerm_network_security_group" "private" {
  name                = "${local.name_prefix}-nsg-private"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}



resource "azurerm_subnet_network_security_group_association" "public" {
  for_each = azurerm_subnet.public

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = azurerm_subnet.private

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.private.id
}
