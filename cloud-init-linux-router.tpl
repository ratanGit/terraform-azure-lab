#cloud-config
hostname: linux-workload
manage_etc_hosts: true

package_update: true
package_upgrade: true

packages:
  - curl
  - wget
  - net-tools
  - htop
  - ca-certificates

runcmd:
  - echo "🚀 Linux workload VM is ready" > /etc/motd
  - timedatectl set-timezone America/Toronto
``