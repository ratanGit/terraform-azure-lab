############################################
# 1. Public IP & Network Interface
############################################
resource "azurerm_public_ip" "guacamole" {
  name                = "${local.name_prefix}-pip-guacamole"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}


resource "azurerm_network_interface" "guacamole" {
  name                = "${local.name_prefix}-nic-guacamole"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.this["public"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.guacamole.id
  }
}

############################################
# 2. Linux VM with Docker Cloud-Init
############################################
resource "azurerm_linux_virtual_machine" "guacamole" {
  name                = "${local.name_prefix}-vm-guacamole"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  size                = var.guac_vm_size
  admin_username      = var.linux_vm_admin_username

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.linux_vm_admin_username
    public_key = trimspace(tls_private_key.guacamole.public_key_openssh)
  }

  network_interface_ids = [azurerm_network_interface.guacamole.id]

  custom_data = base64encode(templatefile("${path.module}/cloud-init-files/cloud-init-docker.tpl", {
    admin_username = var.linux_vm_admin_username
  }))

  os_disk {
    name                 = "${local.name_prefix}-osdisk-guacamole"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.ubuntu_image.publisher
    offer     = var.ubuntu_image.offer
    sku       = var.ubuntu_image.sku
    version   = var.ubuntu_image.version
  }

  vtpm_enabled        = true
  secure_boot_enabled = true
  tags                = merge(local.common_tags, { Role = "Guacamole-Gateway" })
}

############################################
# 3. The "Zero-Touch" Deploy Logic
############################################
resource "null_resource" "guacamole_deploy" {
  # This resource only runs when the VM is READY and the .env is RENDERED
  depends_on = [azurerm_linux_virtual_machine.guacamole, local_file.guacamole_env]

  triggers = {
    # If the blueprint changes, re-run the script
    guac_hash = sha256(join("", [
      file("${path.module}/.env.tpl"),
      file("${path.module}/guacamole/compose.yml")
    ]))
  }

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.guacamole.ip_address
    user        = var.linux_vm_admin_username
    private_key = tls_private_key.guacamole.private_key_pem
  }

  # Step A: Prep and Wait for Cloud-Init
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 5; done",
      "mkdir -p /home/${var.linux_vm_admin_username}/guacamole/nginx"
    ]
  }

  # Step B: Copy EVERYTHING (Rendered .env, compose, and nginx folder)
  provisioner "file" {
    source      = "${path.module}/guacamole/"
    destination = "/home/${var.linux_vm_admin_username}/guacamole"
  }

  # Step C: The Self-Healing Engine
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.linux_vm_admin_username}/guacamole",
      "sudo docker compose up -d",

      "echo 'Waiting for Postgres engine...'",
      "until sudo docker exec guacamole-db pg_isready -U guacamole_user; do sleep 5; done",

      "echo 'Checking for existing schema...'",
      "if ! sudo docker exec guacamole-db psql -U guacamole_user -d guacamole_db -c '\\dt' | grep -q 'guacamole_user'; then",
      "  echo 'Schema missing. Initializing...'",
      "  sudo docker run --rm guacamole/guacamole:latest /opt/guacamole/bin/initdb.sh --postgresql > /tmp/initdb.sql",
      "  sudo docker cp /tmp/initdb.sql guacamole-db:/initdb.sql",
      "  sudo docker exec guacamole-db psql -U guacamole_user -d guacamole_db -f /initdb.sql",
      "  sudo docker restart guacamole-app",
      "  echo 'Database schema successfully initialized.'",
      "else",
      "  echo 'Database already has a schema. Skipping.'",
      "fi",
      "echo '--- DEPLOYMENT COMPLETE ---'"
    ]
  }
}