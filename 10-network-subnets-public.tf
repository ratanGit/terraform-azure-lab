############################################
# Public Subnets (The Perimeter)
############################################

resource "azurerm_subnet" "public" {
  # Filter the main subnets variable for 'public' types
  for_each = { for k, v in var.subnets : k => v if v.type == "public" }

  # Convention: lab-snet-public
  name                 = "${local.name_prefix}-snet-${each.key}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]

  # Architecture Note:
  # These subnets are associated with the Public NSG (SSH/HTTP/HTTPS)
  # and house the Guacamole Gateway VM.
}