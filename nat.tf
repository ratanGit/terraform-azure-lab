resource "azurerm_public_ip" "nat" {
  name                = local.nat_public_ip_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "this" {
  name                = local.nat_gateway_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  for_each = azurerm_subnet.private

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

