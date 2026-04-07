############################################
# Public IP
############################################
resource "azurerm_public_ip" "guacamole" {
  name                = "${local.name_prefix}-guac-pip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  allocation_method = "Static"
  sku               = "Standard"
}

############################################
# Network Interface
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
# Linux VM
############################################
resource "azurerm_linux_virtual_machine" "guacamole" {
  name                = "${local.name_prefix}-guac-vm"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  size                = var.vm_size
  admin_username      = var.vm_admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.guacamole.id
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = tls_private_key.guacamole.public_key_openssh
  }

  os_disk {
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
    templatefile("${path.module}/cloud-init-docker.tpl", {
      vm_admin_username = var.vm_admin_username
    })
  )

  tags = {
    Role = "Guacamole"
  }
}

############################################
# Deploy Guacamole (Docker Compose)
############################################

resource "null_resource" "guacamole_deploy" {

  depends_on = [
    azurerm_linux_virtual_machine.guacamole
  ]

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.guacamole.ip_address
    user        = var.vm_admin_username
    private_key = tls_private_key.guacamole.private_key_pem
  }

  # 1️⃣ Clean old files (prevents stale compose.yml)
  provisioner "remote-exec" {
    inline = [
      "rm -rf /home/${var.vm_admin_username}/guacamole",
      "mkdir -p /home/${var.vm_admin_username}/guacamole"
    ]
  }

  # 2️⃣ Copy guacamole folder (docker-compose.yml + nginx)
  provisioner "file" {
    source      = "${path.module}/guacamole"
    destination = "/home/${var.vm_admin_username}"
  }

  # 3️⃣ Generate .env on the VM (THIS WAS MISSING ✅)
  provisioner "file" {
    content = templatefile(
      "${path.module}/guacamole/.env.tpl",
      {
        guacamole_dns_name = var.guacamole_dns_name
      }
    )
    destination = "/home/${var.vm_admin_username}/guacamole/.env"
  }

  # 4️⃣ Wait for cloud-init AND docker daemon, then start compose
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "until systemctl is-active --quiet docker; do sleep 2; done",
      "cd /home/${var.vm_admin_username}/guacamole",
      "sudo docker compose config",
      "sudo docker compose up -d"
    ]
  }

  # 5️⃣ Trigger redeploy on file change
  triggers = {
    guacamole_files = sha256(join("", [
      for f in fileset("${path.module}/guacamole", "**") :
      file("${path.module}/guacamole/${f}")
    ]))
  }
}