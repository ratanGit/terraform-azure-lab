#cloud-config
package_update: true
package_upgrade: true

runcmd:
  - curl -fsSL https://get.docker.com | sh
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ${vm_admin_username}
