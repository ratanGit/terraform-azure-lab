############################################
# Private Subnet NSG (The Vault)
############################################

resource "azurerm_network_security_group" "nsg_private" {
  # Convention: lab-nsg-private
  name                = "${local.name_prefix}-nsg-private"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  tags = merge(local.common_tags, {
    Role    = "Private-Workload"
    Purpose = "Internal-Security"
    Zone    = "Trusted"
  })
}

############################################
# Inbound Rules
############################################

# 1. Allow traffic ONLY from the Public Subnet (Guacamole / NPM)
resource "azurerm_network_security_rule" "private_from_public" {
  name                        = "Allow-Inbound-From-Public"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  
  # Note: Keeping this broad (*) for now to allow SSH/RDP/WinRM 
  # for your internal lab machines.
  destination_port_range      = "*" 
  
  # Logic: Pull the CIDR directly from your public subnet definition
  source_address_prefix       = azurerm_subnet.public["public"].address_prefixes[0]
  destination_address_prefix  = "VirtualNetwork"
  
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_private.name
}

############################################
# NSG -> Subnet Association
############################################

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = azurerm_subnet.private

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg_private.id
}