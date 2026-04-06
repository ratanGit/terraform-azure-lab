############################################
# Public IP for Guacamole VM
############################################

resource "azurerm_public_ip" "guacamole" {
  name                = "${local.name_prefix}-guac-pip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  allocation_method = "Static"
  sku               = "Standard"
}

############################################
# Network Interface for Guacamole VM
############################################

resource "azurerm_network_interface" "guacamole" {
  name                = "${local.name_prefix}-guac-nic"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.public["public"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.guacamole.id
  }
}

############################################
# Linux VM (Ubuntu 24.04 LTS)
############################################

resource "azurerm_linux_virtual_machine" "guacamole" {
  name                = "${local.name_prefix}-guac-vm"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  size           = var.vm_size
  admin_username = var.vm_admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.guacamole.id
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.guacamole.public_key_openssh
  }

  os_disk {
    name                 = "${local.name_prefix}-guac-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

source_image_reference {
  publisher = "Canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "server-gen1"
  version   = "latest"
}


  custom_data = base64encode(
    file("${path.module}/cloud-init-docker.yaml")
  )

  tags = {
    Role = "Guacamole"
  }
}
