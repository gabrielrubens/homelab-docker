# 🏠 Homelab Documentation

A reference for setting up and maintaining my personal Homelab environment, focused on self-hosted services, Docker containers, and system automation.

---

## 🔧 Hardware

### Mini PC – Beelink Mini S13

| Component        | Details                                                |
|------------------|--------------------------------------------------------|
| **Model**        | Beelink Mini S13                                       |
| **CPU**          | Intel Twin Lake-N150 (4C/4T, up to 3.6 GHz)            |
| **RAM**          | 16 GB DDR4 @ 3200 MHz                                  |
| **Storage**      | 500 GB M.2 SATA3 SSD                                   |
| **Expansion**    | 2× M.2 slots (PCIe 3.0 x4/SATA3 & PCIe 3.0 x1)         |
| **GPU**          | Intel UHD Graphics                                     |
| **Networking**   | Gigabit Ethernet, Wi-Fi 6, Bluetooth 5.2              |
| **Video Output** | Dual HDMI (4K@60Hz)                                    |
| **USB**          | 4× USB 3.0                                             |
| **Power**        | 12V DC / 3A                                            |
| **OS**           | Ubuntu Server                                          |

🔹 **Notes**:

- Low power, silent operation (~15–25W)
- Ideal for Docker, media server, Pi-hole, VPN, etc.

---

## 🛆 Docker Containers

All Docker Compose Files are located on the project [gabrielrubens/homelab-docker](https://github.com/gabrielrubens/homelab-docker/), and there you can see the subfolders, such as gabrielrubens/homelab-dockerpihole/docker-compose.yml.
To deploy a new Container, we need to go to Portainer and Add Stack.


### ✅ Running Containers

| Container      | Description             | Image                    | Ports        | Volumes                                     | Notes                  |
|----------------|-------------------------|--------------------------|--------------|---------------------------------------------|------------------------|
| **Pi-hole**    | DNS-level ad blocker    | `pihole/pihole:latest`   | `53/udp, 80` | `/etc/pihole`, `/etc/dnsmasq.d`             | Static IP recommended  |
| **Portainer**  | Container management UI | `portainer/portainer-ce` | `9000`       | `/var/run/docker.sock:/var/run/docker.sock` | Use for GUI management |

### 📁 Planned Containers

- Netdata
- WireGuard
- Watchtower
- Home Assistant
- Jellyfin or Plex
- Nextcloud
- Uptime Kuma
- Vaultwarden

Example do add on the table when deployed:
| **WireGuard**  | VPN tunnel access       | `linuxserver/wireguard`  | `51820/udp`  | `/config`, `/lib/modules`                   | Enable port forwarding |
| **Watchtower** | Auto-update containers  | `containrrr/watchtower`  | —            | Docker socket                               | Runs on a schedule     |


---

## 🌐 Networking Setup

- Router: [Altice Wi-Fi 6 GPON FGW](https://www.alticelabs.com/wp-content/uploads/2023/10/FL_GPON_FGW-Wi-Fi6_EN.pdf)
- Static IP assigned to Mini PC
- DNS set to Pi-hole IP: `192.168.1.x`
- Port forwarding enabled for:
  - `9000/tcp` (Portainer if remote access needed)
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
