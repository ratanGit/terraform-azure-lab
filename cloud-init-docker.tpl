#cloud-config
package_update: true
package_upgrade: true

runcmd:
  - systemctl daemon-reexec
  
  # Install Docker (official convenience script)
  - curl -fsSL https://get.docker.com | sh
  
  # Ensure Docker service is configured for the standard engine
  - systemctl disable docker.socket
  - systemctl stop docker.socket
  - systemctl enable docker.service
  - systemctl start docker.service
  
  # Grant your user docker permissions (for future manual SSH work)
  - usermod -aG docker ${admin_username}
  
  # Final signal for your Terraform remote-exec
  - echo "Cloud-init execution completed" > /var/log/cloud-init-done.log