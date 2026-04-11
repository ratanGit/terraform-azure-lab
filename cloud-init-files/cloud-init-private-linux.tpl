#cloud-config
hostname: webapps
manage_etc_hosts: true

package_update: true
package_upgrade: true

packages:
  - curl
  - ca-certificates
  - gnupg
  - lsb-release

runcmd:
  # Re-exec systemd to avoid any transient unit issues
  - systemctl daemon-reexec

  # Install Docker (official convenience script)
  - curl -fsSL https://get.docker.com | sh

  # Ensure Docker daemon is enabled and running
  - systemctl disable docker.socket
  - systemctl stop docker.socket
  - systemctl enable docker.service
  - systemctl start docker.service

  # Add Linux admin user to docker group
  - usermod -aG docker ${admin_username}

  # Signal completion
  - echo "Cloud-init execution completed successfully" > /var/log/cloud-init-done.log
