###############################################################################
# Linux Router (NAT Gateway Replacement)
###############################################################################

############################################
# Public IP (Router WAN)
############################################

resource "azurerm_public_ip" "router" {
  name                = "${local.name_prefix}-pip-router"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(local.common_tags, {
    Role = "Linux-Router-WAN"
  })
}

############################################
# Router NICs
############################################

# WAN NIC → Public subnet (locals-driven)
resource "azurerm_network_interface" "router_wan" {
  name                = "${local.name_prefix}-nic-router-wan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "wan"
    subnet_id                     = azurerm_subnet.this["public"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.router.id
  }

  tags = merge(local.common_tags, { Role = "Router-WAN" })
}

# LAN NIC → Private subnet
resource "azurerm_network_interface" "router_lan" {
  name                = "${local.name_prefix}-nic-router-lan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "lan"
    subnet_id                     = azurerm_subnet.this["private"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(local.common_tags, { Role = "Router-LAN" })
}

############################################
# Route Table (Private → Router)
############################################

resource "azurerm_route_table" "private_default" {
  name                = "${local.name_prefix}-rt-private"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  route {
    name                   = "default-via-linux-router"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.router_lan.private_ip_address
  }

  tags = local.common_tags
}

resource "azurerm_subnet_route_table_association" "private" {
  subnet_id      = azurerm_subnet.this["private"].id
  route_table_id = azurerm_route_table.private_default.id
}

############################################
# Linux Router VM
############################################

resource "azurerm_linux_virtual_machine" "router" {
  name                = "${local.name_prefix}-vm-router"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  size           = var.linux_vm_size
  admin_username = var.linux_vm_admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.linux_vm_admin_username
    public_key = trimspace(tls_private_key.guacamole.public_key_openssh)
  }

  network_interface_ids = [
    azurerm_network_interface.router_wan.id,
    azurerm_network_interface.router_lan.id
  ]

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = merge(local.common_tags, { Role = "Linux-Router" })
}