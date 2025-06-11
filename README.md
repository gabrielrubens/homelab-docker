# 🏠 Homelab Documentation

A reference for setting up and maintaining my personal Homelab environment, focused on self-hosted services, Docker containers, and system automation.

---

## 🐳 Docker Containers

All Docker Compose files are located in the GitHub project [gabrielrubens/homelab-docker](https://github.com/gabrielrubens/homelab-docker/). Each container has its own subfolder, for example:  
`homelab-docker/pihole/docker-compose.yml`

To deploy a new container:
1. Go to **Portainer → Stacks → Add Stack**.
2. Paste the corresponding `docker-compose.yml`.
3. Deploy the container.

### ✅ Running Containers

| Container      | Description              | Image                      | Ports        | Volumes                                     | Notes                          |
|----------------|--------------------------|----------------------------|--------------|---------------------------------------------|--------------------------------|
| **Dashy**      | Homelab dashboard UI     | `lissy93/dashy:latest`     | `4000`       | `/conf.yml`                                 | Web UI for all services        |
| **Portainer**  | Container management UI  | `portainer/portainer-ce`   | `9000`       | `/var/run/docker.sock:/var/run/docker.sock` | Use for GUI management         |
| **Pi-hole**    | DNS-level ad blocker     | `pihole/pihole:latest`     | `53/udp, 80` | `/etc/pihole`, `/etc/dnsmasq.d`             | Static IP recommended          |
| **Netdata**    | Real-time system metrics | `netdata/netdata:latest`   | `19999`      | `/etc/netdata`, `/var/lib/netdata`, etc.    | Web UI for monitoring          |
| **Glances**    | Simple system monitoring | `nicolargo/glances:latest` | `61208`      | `/var/run/docker.sock`, `/proc`, `/sys`     | Web UI mode (`glances -w`)     |
| **Homepage.dev** | Simple static homepage  | `homepage-dev/homepage:latest` | `3000`       | `/config.yml`                               | Minimal link dashboard        |

### 📁 Planned Containers

- WireGuard
- Watchtower
- Home Assistant
- Jellyfin or Plex
- Nextcloud
- Uptime Kuma
- Vaultwarden

Example to add to the table when deployed:

| **WireGuard**  | VPN tunnel access       | `linuxserver/wireguard`  | `51820/udp`  | `/config`, `/lib/modules`                   | Enable port forwarding |
| **Watchtower** | Auto-update containers  | `containrrr/watchtower`  | —            | Docker socket                               | Runs on a schedule     |

---
### 🗂️ Portainer

We need to make sure that we have these volume because the other Containers will use it

```bash
docker volume create \
  --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/home/gabriel/dev/homelab-docker \
  homelab-docker
```

---
### 🔐 UFW Firewall Rules

After adding or removing a container that exposes a port, update **UFW (Uncomplicated Firewall)** to ensure proper access:

```bash
# Allow port (example: Dashy on port 4000)
sudo ufw allow 4000/tcp comment "Allow Dashy dashboard"

# Remove port (if container is deleted)
sudo ufw delete allow 4000/tcp

# View all firewall rules
sudo ufw status numbered

# Delete by rule number (replace <number> with actual rule number)
sudo ufw delete <number>
```

---

## 🌐 Networking Setup

- Router: [Altice Wi-Fi 6 GPON FGW](https://www.alticelabs.com/wp-content/uploads/2023/10/FL_GPON_FGW-Wi-Fi6_EN.pdf)
- Static IP assigned to Mini PC
- DNS set to Pi-hole IP: `192.168.1.x`
- Port forwarding enabled for:
  - `9000/tcp` (Portainer, if remote access is needed)
- Local domain resolution via Pi-hole DNS settings

---

## 🛠️ Installation Notes

```bash
# Basic Ubuntu Setup
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
```

---

## 🔄 Backup & Automation (Planned)

- Automatic daily backups using `rsync` to external USB.
- Configs stored in Git (private repo).
- Monitor uptime with Uptime Kuma.
- Update containers via Watchtower.

---

## 💻 Hardware

### Mini PC – Beelink Mini S13

| Component        | Details                                                |
|------------------|--------------------------------------------------------|
| **Model**        | Beelink Mini S13                                       |
| **CPU**          | Intel Twin Lake-N150 (4C/4T, up to 3.6 GHz)            |
| **RAM**          | 16 GB DDR4 @ 3200 MHz                                  |
| **Storage**      | 500 GB M.2 SATA3 SSD                                   |
| **Expansion**    | 2× M.2 slots (PCIe 3.0 x4/SATA3 & PCIe 3.0 x1)         |
| **GPU**          | Intel UHD Graphics                                     |
| **Networking**   | Gigabit Ethernet, Wi-Fi 6, Bluetooth 5.2               |
| **Video Output** | Dual HDMI (4K@60Hz)                                    |
| **USB**          | 4× USB 3.0                                             |
| **Power**        | 12V DC / 3A                                            |
| **OS**           | Ubuntu Server                                          |

**Notes**:

- Low power, silent operation (~15–25W)
- Ideal for Docker, media server, Pi-hole, VPN, etc.
