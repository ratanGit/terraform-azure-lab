#cloud-config
hostname: linux-router
manage_etc_hosts: true

package_update: true
package_upgrade: true

packages:
  - iptables-persistent
  - net-tools
  - curl

runcmd:
  # Ensure IP forwarding persists across reboots
  - sysctl -w net.ipv4.ip_forward=1
  - sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

  # Flush existing rules (safe on first boot)
  - iptables -F
  - iptables -t nat -F

  # NAT: Masquerade all outbound traffic via WAN (eth0)
  - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

  # Allow forwarding between LAN (eth1) and WAN (eth0)
  - iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
  - iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

  # Persist iptables rules
  - netfilter-persistent save

  # Final confirmation
  - echo "Linux router cloud-init complete" > /var/log/cloud-init-router.log