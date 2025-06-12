# 🏠 Homelab Documentation

A reference for setting up and maintaining my personal Homelab environment, focused on self-hosted services, Docker containers, and system automation.

---

## 📂 Repository Structure

```
homelab-docker/
├── README.md                 # This file
├── docker-compose.yml        # "Umbrella" compose bringing in all services
├── dashy/
│   └── docker-compose.yml
├── glances/
│   └── docker-compose.yml
├── homepage/
│   ├── docker-compose.yml
│   └── config/               # homepage configs (bookmarks, widgets, etc.)
├── netdata/
│   └── docker-compose.yml
└── pihole/
    └── docker-compose.yml
```

---

## 🚀 Deploying All Services (Umbrella Compose)

From the project root, you can bring up *all* services at once:

```bash
# Pull latest images
docker-compose pull

# (Re)create containers in detached mode
docker-compose up -d
```

To update after pushing changes to GitHub:

1. On the server: `cd ~/homelab-docker && git pull`
2. `docker-compose pull`
3. `docker-compose up -d`

> **Tip:** You can use Portainer purely for monitoring — all deployments now happen via this umbrella compose in Git.

---

## ✅ Running Containers

| Container        | Description               | Ports      | Notes                                     |
| ---------------- | ------------------------- | ---------- | ----------------------------------------- |
| **Dashy**        | Homelab dashboard UI      | 4000→8080  | Lissy93 Dashy configuration in `dashy/`   |
| **Glances**      | System resource monitor   | 61208      | Web UI mode (`glances -w`) in `glances/`  |
| **Homepage.dev** | Custom homepage/startpage | 3000       | Configs in `homepage/config/`             |
| **Netdata**      | Real-time system metrics  | 19999      | Named volumes for data in root `volumes:` |
| **Pi-hole**      | DNS-level ad blocker      | 53/udp, 80 | Host networking                           |

---

## 🗂️ Volumes & Shared Data

Declaring named volumes at the bottom of `docker-compose.yml` lets each service map where it needs without hardcoding host paths:

```yaml
volumes:
  netdataconfig:
  netdatalib:
  netdatacache:
  # You can add more shared/host-bind volumes here if needed
```

If you prefer a single host directory for all service configs/data, you can bind-mount it:

```bash
docker volume create \
  --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/home/gabriel/homelab-docker \
  homelab-docker
```

And then in compose:

```yaml
services:
  dashy:
    volumes:
      - homelab-docker/dashy/conf.yml:/app/user-data/conf.yml:ro
...
volumes:
  homelab-docker:
    external: true
```

---

## 🔐 Firewall (UFW) Rules

Whenever you expose a new port, allow it:

```bash
sudo ufw allow 4000/tcp comment "Allow Dashy"
sudo ufw allow 3000/tcp comment "Allow Homepage"
```

Remove old rules as needed:

```bash
sudo ufw delete allow 4000/tcp
```

---

## 🌐 Networking Setup

* **Static IP** assigned to your homelab server.
* **DNS** set to Pi-hole IP (`192.168.1.x`).
* **Port forwarding** in router, e.g. port 9000 for remote Portainer access.

---

## 🛠️ Initial Server Setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose git -y
sudo usermod -aG docker $USER
# Clone project:
git clone https://github.com/gabrielrubens/homelab-docker.git
cd homelab-docker
```

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
