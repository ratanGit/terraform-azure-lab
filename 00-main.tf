###########################################################
# 1. LOCAL PREP: Render the .env file from the .tpl
# This stays on your laptop in the "guacamole" folder
###########################################################
resource "local_file" "guacamole_env" {
  content = templatefile("${path.module}/.env.tpl", {
    base_path          = "/home/${var.vm_admin_username}/guacamole"
    guac_db_password   = var.guac_db_password
    npm_db_password    = var.npm_db_password
    guacamole_dns_name = azurerm_public_ip.guacamole.ip_address
    guac_db_user       = "guacamole_user"
    guac_db_name       = "guacamole_db"
  })
  filename = "${path.module}/guacamole/.env"
}

