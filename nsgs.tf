############################################
# Public Subnet NSG
############################################

resource "azurerm_network_security_group" "public" {
  name                = "${local.name_prefix}-nsg-public"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

# Allow SSH from My IP (temporary / admin access)
resource "azurerm_network_security_rule" "public_ssh" {
  name                        = "Allow-SSH-MyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.public.name
}

# Allow HTTPS (Guacamole)
resource "azurerm_network_security_rule" "public_https" {
  name                        = "Allow-HTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.public.name
}

# Associate Public NSG to Public Subnet
resource "azurerm_subnet_network_security_group_association" "public" {
  for_each = azurerm_subnet.public

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.public.id
}

############################################
# Private Subnet NSG
############################################

resource "azurerm_network_security_group" "private" {
  name                = "${local.name_prefix}-nsg-private"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
}

# Allow traffic from within the VNet (Guacamole -> private VMs)
resource "azurerm_network_security_rule" "private_vnet_inbound" {
  name                        = "Allow-VNet-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.private.name
}

# Associate Private NSG to Private Subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = azurerm_subnet.private

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.private.id
}
