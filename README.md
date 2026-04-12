# Azure Guacamole Lab – Secure Remote Access Architecture

## Overview


This project deploys a **secure Azure lab environment** using **Terraform**, centered around **Apache Guacamole** as a web‑based remote access gateway.  
It enables **browser‑based SSH and RDP access** to private workloads without exposing internal machines directly to the internet.

The design follows **modern Zero Trust principles**:

*   No public IPs on internal workloads
*   Controlled ingress via Guacamole
*   Controlled egress via a custom Linux router (no Azure NAT Gateway)

***

## High-Level Architecture

![Architecture Diagram](./images/image.png)](./images/image.png)

<small>*Figure: High-level architecture of the Azure Guacamole lab*</small>

### Key Components

*   **Azure Virtual Network (VNet‑Lab‑Guacamole)**
*   **Public Subnet**
    *   Apache Guacamole Gateway
    *   Linux Router (NAT replacement)
*   **Private Subnet**
    *   Windows Server lab machines (IAM, migration, testing)
    *   Internal Linux / Docker workloads
*   **Internet**
    *   HTTPS access to Guacamole
    *   Outbound internet via Linux router

***

## Design Goals

*   ✅ **No public IPs on internal workloads**
*   ✅ **Browser‑based access (SSH / RDP)**
*   ✅ **Replace Azure NAT Gateway (cost optimization)**
*   ✅ **Environment‑driven (lab / prod ready)**
*   ✅ **Infrastructure as Code (Terraform)**

***

## Network Flow Explanation

### Inbound (User Access)

1.  User connects over the **Internet (HTTPS)**
2.  Traffic reaches **Apache Guacamole** in the **public subnet**
3.  Guacamole brokers:
    *   SSH to Linux VMs
    *   RDP to Windows Servers
4.  Connections are proxied **into the private subnet**
5.  Internal machines remain **non‑internet‑facing**

### Outbound (Internet Access from Private Subnet)

1.  Private VMs send outbound traffic
2.  Azure Route Table sends `0.0.0.0/0` to **Linux Router**
3.  Linux Router performs **NAT (iptables)**
4.  Traffic exits via router’s **public IP**
5.  No Azure NAT Gateway required

***

## Key Features

### Apache Guacamole Gateway

*   Web‑based access to **SSH and RDP**
*   Single entry point
*   Integrates with **Microsoft Entra ID** (planned/optional)
*   No VPN required for users

### Linux Router (NAT Replacement)

*   Ubuntu‑based VM
*   Dual‑homed NICs:
    *   WAN (public subnet)
    *   LAN (private subnet)
*   Uses `iptables` for NAT
*   Replaces **Azure NAT Gateway** to reduce cost

### Private Workloads

*   Windows Server lab VMs
*   Internal Linux VMs
*   Docker‑based applications
*   No public IPs
*   Reachable only via Guacamole or internal routing

***
## Infrastructure as Code

*   **Terraform**
    *   Environment‑driven variables (`lab`, `prod`)
    *   Centralized locals for naming & tagging
    *   Modular, readable structure
*   **Terraform‑managed SSH keys**
    *   RSA 4096
    *   Shared securely across Linux infrastructure

***

## Outputs & Access Information

After deployment, Terraform outputs structured information including:

*   **Guacamole public IP & HTTPS URL**
*   **Linux Router public IP**
*   **Private Linux VM IP**
*   **Ready‑to‑use SSH commands**

Example:

```bash
terraform output access_information
```

This makes the environment easy to consume both by humans and downstream Terraform projects (`remote_state`).

***

## Security Considerations

*   No public access to private subnets
*   SSH/RDP access only via Guacamole
*   Controlled outbound flow via Linux router
*   Centralized SSH key management
*   NSG hardening supported (optional extension)

***

## Cost Optimization

| Component | Azure Native         | This Project    |
| --------- | -------------------- | --------------- |
| NAT       | Azure NAT Gateway    | Linux Router    |
| Cost      | High (monthly fixed) | Low (VM only)   |
| Control   | Limited              | Full (iptables) |

This design significantly reduces monthly Azure spend for lab and non‑production environments.

***

## Requirements

*   Terraform ≥ 1.x
*   Azure CLI authenticated
*   SSH key (Terraform‑generated or existing)
*   Azure subscription

***

## Future Enhancements

*   WireGuard VPN on Linux Router
*   High‑Availability router setup
*   Entra ID enforced Guacamole auth
*   Modularization for reuse
*   CI/CD pipeline for Terraform

***

## NGINX Proxy
# Redirect root to Guacamole
location = / {
    return 301 /guacamole/;
}

# Apache Guacamole reverse proxy
location /guacamole/ {
    proxy_pass http://guacamole-app:8080/guacamole/;
    proxy_buffering off;
    proxy_http_version 1.1;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;

    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
}

## Author

**Ratan Mohapatra**  
Azure | Zero Trust | Cloud Architecture

***



## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.