#cloud-config
package_update: true
package_upgrade: true

runcmd:
  - systemctl daemon-reexec

  # Install Docker (official)
  - curl -fsSL https://get.docker.com | sh

  # Disable socket activation (DO NOT MASK)
  - systemctl disable docker.socket
  - systemctl stop docker.socket

  # Enable and start Docker normally
  - systemctl enable docker.service
  - systemctl start docker.service

  # Non-root Docker access (new sessions)
  - usermod -aG docker ${vm_admin_username}
