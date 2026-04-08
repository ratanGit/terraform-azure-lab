############################################
# Private Subnets (The Vault)
############################################

resource "azurerm_subnet" "private" {
  # Filter the main subnets variable for 'private' types
  for_each = { for k, v in var.subnets : k => v if v.type == "private" }

  # Convention: lab-snet-private
  name                 = "${local.name_prefix}-snet-${each.key}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.cidr]

  # Architecture Note: 
  # Private subnets in this lab are associated with the NAT Gateway 
  # and the Private NSG in their respective .tf files.
}