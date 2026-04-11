############################################
# Private Linux VM - NIC
############################################

resource "azurerm_network_interface" "private_linux" {
  name                = "${local.name_prefix}-nic-private-linux"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.this["private"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(local.common_tags, {
    Role = "Private-Linux"
  })
}

############################################
# Private Linux VM
############################################

resource "azurerm_linux_virtual_machine" "private_linux" {
  name                = "${local.name_prefix}-vm-private-linux"
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
    azurerm_network_interface.private_linux.id
  ]


  # Pass admin_username explicitly to cloud-init
  custom_data = base64encode(
    templatefile(
      "${path.module}/cloud-init-files/cloud-init-private-linux.tpl",
      {
        admin_username = var.linux_vm_admin_username
      }
    )
  )


  os_disk {
    name                 = "${local.name_prefix}-osdisk-private-linux"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }

  tags = merge(local.common_tags, {
    Role = "Private-Linux"
    Zone = "Private"
  })
}