############################################
# Terraform-managed SSH key for Guacamole VM
# Azure requires RSA keys (ECDSA/ED25519 not supported)
############################################

resource "tls_private_key" "guacamole" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

############################################
# Write private key locally for SSH access
############################################

resource "local_file" "guacamole_private_key" {
  filename        = "${path.module}/guac"
  content         = tls_private_key.guacamole.private_key_pem
  file_permission = "600"
}
