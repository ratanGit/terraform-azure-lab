############################################
# Private Subnet NSG (The Vault)
############################################

resource "azurerm_network_security_group" "nsg_private" {
  name                = "${local.name_prefix}-nsg-private"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = merge(local.common_tags, {
    Role    = "Private-Workload"
    Purpose = "Internal-Security"
    Zone    = "Trusted"
  })
}

############################################
# Inbound Rules
############################################

# Allow traffic ONLY from the Public Subnet (Guacamole / NPM)
resource "azurerm_network_security_rule" "private_from_public" {
  name                   = "Allow-Inbound-From-Public"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "*"
  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = azurerm_subnet.this["public"].address_prefixes[0]
  destination_address_prefix = "VirtualNetwork"

  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_private.name
}

############################################
# NSG -> Private Subnet Association
############################################

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each = local.private_subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_private.id
}

############################################
# Public Subnet NSG (The Perimeter)
############################################

resource "azurerm_network_security_group" "nsg_public" {
  # Convention: lab-nsg-public
  name                = "${local.name_prefix}-nsg-public"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  tags = merge(local.common_tags, {
    Role    = "Public-Gateway"
    Purpose = "External-Connectivity"
    Scope   = "DMZ"
  })
}

############################################
# Inbound Rules
############################################

# 1. SSH Management (Restricted to My IP)
resource "azurerm_network_security_rule" "public_ssh" {
  name                        = "Allow-SSH-MyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_ip # Your Ottawa Management IP
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

# 2. HTTP (Certbot / Let's Encrypt Validation)
resource "azurerm_network_security_rule" "public_http" {
  name                        = "Allow-HTTP-Any"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

# 3. HTTPS (Main Application Traffic)
resource "azurerm_network_security_rule" "public_https" {
  name                        = "Allow-HTTPS-Any"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

# 4. NPM Admin UI (Restricted to My IP)
resource "azurerm_network_security_rule" "public_npm_admin" {
  name                        = "Allow-NPM-Admin-81"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "81"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}

############################################
# NSG -> Subnet Association
############################################


resource "azurerm_subnet_network_security_group_association" "public" {
  for_each = local.public_subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}
