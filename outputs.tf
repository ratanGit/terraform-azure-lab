output "resource_group_name" {
  value = data.azurerm_resource_group.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = merge(
    { for k, s in azurerm_subnet.public : k => s.id },
    { for k, s in azurerm_subnet.private : k => s.id }
  )
}

output "guacamole_public_ip" {
  description = "Public IP of the Guacamole VM"
  value       = azurerm_public_ip.guacamole.ip_address
}

output "guacamole_ssh_user" {
  description = "SSH username for the Guacamole VM"
  value       = var.vm_admin_username
}

output "guacamole_ssh_key_path" {
  description = "Path to the private SSH key for the Guacamole VM"
  value       = local_file.guacamole_private_key.filename
}


output "guacamole_ssh_command" {
  description = "SSH command for the Guacamole VM"
  value       = "ssh -i ${local_file.guacamole_private_key.filename} ${var.vm_admin_username}@${azurerm_public_ip.guacamole.ip_address}"
}
