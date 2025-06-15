# 🏠 Homelab Documentation

A reference for setting up and maintaining my personal Homelab environment, focused on self-hosted services, Docker containers, and system automation via Ansible.

---

## ✅ Current Containers

| Service   | Image                             | Ports                          | Notes                                 |
| --------- | --------------------------------- | ------------------------------ | ------------------------------------- |
| Dashy     | ghcr.io/lissy93/dashy:latest      | `0.0.0.0:4000→8080`            | Dashboard UI                          |
| Homepage  | ghcr.io/gethomepage/homepage:latest | `0.0.0.0:{{ homepage_port }}→3001` | Config-driven startpage              |
| Glances   | nicolargo/glances:latest          | `0.0.0.0:{{ glances_port }}→61208` | System monitor (`glances -w`)       |
| Netdata   | netdata/netdata:latest            | `0.0.0.0:19999`                | Real-time metrics                     |
| Pi-hole   | pihole/pihole:latest              | DNS TCP/UDP 53, HTTP 80        | DNS-level ad blocker                  |
| Portainer | portainer/portainer-ce:latest      | HTTP `9000`                    | (Optional) container GUI              |


---

## 📂 Repository Structure

```
homelab-docker/
├── README.md                     # This file
├── deploy.sh                     # Wrapper script for local/remote deployment
├── docker-compose.yml            # "Umbrella" compose bringing in all services
├── docker-compose.override.yml   # Local overrides (bind-mounts, dev profiles)
├── ansible/                      # Ansible playbook, inventory, and roles
│   ├── inventory/hosts.yml
│   ├── host_vars/
│   ├── group_vars/
│   ├── requirements.yml
│   ├── playbook.yml
│   └── roles/
│       ├── git-clone/
│       ├── docker-compose/
│       └── ufw/
├── dashy/
│   ├── docker-compose.yml
│   └── conf.yml
├── glances/
│   └── docker-compose.yml
├── homepage/
│   ├── docker-compose.yml
│   └── config/                   # homepage configs (bookmarks, widgets, etc.)
├── netdata/
│   └── docker-compose.yml
└── pihole/
    └── docker-compose.yml
```

---

## 🚀 Deployment with Ansible (Recommended)

Everything—cloning the repo, updating code, tearing down and re-creating containers, and managing UFW—is automated via Ansible.

1. **Install dependencies** (once):

   ```bash
   sudo apt update && sudo apt install ansible git python3-pip -y
   ansible-galaxy collection install -r ansible/requirements.yml
   ```

2. **Run the playbook**:

   - **Locally on the server**:
     ```bash
     ./deploy.sh
     ```
   - **Remotely from your workstation** (SSH key required):
     ```bash
     ./deploy.sh --server
     ```

   The playbook will:
   - Clone/update `homelab-docker` repo
   - Install or update Docker Compose plugin / pip fallback
   - Tear down any existing stack
   - Bring up the full umbrella compose (with `docker-compose.yml` and `docker-compose.override.yml` if present)
   - Install & enable UFW, then add/remove rules for each service port

3. **Adding or Removing a Service**:
   - Create a new subfolder (e.g. `myservice/`) with its own `docker-compose.yml`.
   - In the root `docker-compose.yml`, add an `extends:` entry under `services:`.
   - Optionally, add dev-bind overrides in `docker-compose.override.yml` under your `dev` profile.
   - Update UFW role (`ansible/roles/ufw/tasks/main.yml`) to allow the new service’s port, using the pattern:
     ```yaml
     - name: Allow MyService (HTTP)
       ufw:
         rule: allow
         port: "{{ myservice_port }}"
         proto: tcp
         comment: "Allow MyService HTTP"
     ```

4. **Firewall Rules (UFW)**  
   The Ansible role will ensure UFW is installed, enabled, and has rules for:
   - SSH
   - Dashy (port `{{ dashy_port }}`)
   - Homepage (port `{{ homepage_port }}`)
   - Glances (port `{{ glances_port }}`)
   - Netdata (port `{{ netdata_port }}`)
   - Pi-hole DNS (TCP/UDP 53) & web UI (TCP 80)
   - Portainer (if used)

   To manually add or remove rules:
   ```bash
   sudo ufw allow 4000/tcp comment "Allow Dashy"
   sudo ufw delete allow 4000/tcp
   ```

---

## ✅ Running Containers (Manual)

If you prefer the classic `docker-compose` approach:

```bash
# Bring up all services
docker-compose pull
docker-compose up -d

# With overrides
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

---

## 🗂️ Volumes & Shared Data

Named volumes are declared in `docker-compose.yml`:

```yaml
volumes:
  homepage_config: {}
  pihole_data: {}
  dnsmasq_data: {}
  netdataconfig: {}
  netdatalib: {}
  netdatacache: {}
```

For a single bind-mount directory:

```yaml
volumes:
  homelab_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/gabriel/homelab-docker
```

---

## 🌐 Networking Setup

- **Static IP** for homelab server.
- **DNS** clients point at Pi-hole IP (e.g. `192.168.1.92`).
- **Port forwarding** on router for remote access (e.g. Portainer on `9000`).

---

## 🛠️ Initial Server Setup

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose git ufw -y
sudo usermod -aG docker $USER
```

Clone & deploy:

```bash
git clone https://github.com/gabrielrubens/homelab-docker.git
cd homelab-docker
./deploy.sh
```

---

## 💻 Hardware

### Mini PC – Beelink Mini S13

| Component        | Details                                                |
|------------------|--------------------------------------------------------|
| **Model**        | Beelink Mini S13                                       |
| **CPU**          | Intel Twin Lake-N150 (4C/4T, up to 3.6 GHz)            |
| **RAM**          | 16 GB DDR4 @ 3200 MHz                                  |
| **Storage**      | 500 GB M.2 SATA3 SSD                                   |
| **Expansion**    | 2 × M.2 slots (PCIe 3.0 x4/SATA3 & PCIe 3.0 x1)        |
| **GPU**          | Intel UHD Graphics                                     |
| **Networking**   | Gigabit Ethernet, Wi-Fi 6, Bluetooth 5.2               |
| **Video Output** | Dual HDMI (4K @ 60 Hz)                                 |
| **USB**          | 4 × USB 3.0                                            |
| **Power**        | 12 V DC / 3 A                                          |
| **OS**           | Ubuntu Server                                          |

---

> **Note:** Always keep secrets (SSH keys, TLS private keys, Ansible `host_vars/`) out of Git—add them to `.gitignore` and use an external vault or CI/CD secrets manager.

```
# .gitignore (excerpt)
.env
*.log
docker-compose.override.yml
netdata/netdatacache/
netdata/netdatalib/
pihole/etc-pihole/
pihole/etc-dnsmasq.d/
homepage/config/logs/
ansible/host_vars/
ansible/group_vars/localhost.yml
```

---

## How to Add a New App/Container

This section outlines the general steps to add a new Dockerized application to this homelab setup.

**Prerequisites:**
*   Basic understanding of Docker and Docker Compose.
*   Familiarity with the project structure.

**Steps:**

1.  **Create the App's Docker Compose File:**
    *   Create a new directory for the application under `/workspace/` (e.g., `/workspace/newapp/`).
    *   Inside this directory, create a `docker-compose.yml` file (e.g., `/workspace/newapp/docker-compose.yml`).
    *   Define the service for your new application. At a minimum, this usually includes `image`, `container_name`, and `restart` policy.
        ```yaml
        # /workspace/newapp/docker-compose.yml
        services:
          newapp:
            image: vendor/newapp-image:latest
            container_name: newapp
            restart: unless-stopped
            # Ports and volumes are typically defined in the root docker-compose.override.yml
        ```

2.  **Include the New App in the Main `docker-compose.yml`:**
    *   Edit the root `/workspace/docker-compose.yml` file.
    *   Add an entry for your new service using the `extends` keyword to include its configuration.
        ```yaml
        # /workspace/docker-compose.yml
        services:
          # ... other services ...
          newapp:
            extends:
              file: ./newapp/docker-compose.yml
              service: newapp
        ```

3.  **Configure Ports and Volumes in `docker-compose.override.yml`:**
    *   Edit the root `/workspace/docker-compose.override.yml` file.
    *   Add a service block for `newapp`.
    *   **Ports:** Map a host port to the container's exposed port. Use an environment variable for the host port (e.g., `${newapp_port:-default_port_here}`).
    *   **Volumes:** If the application requires persistent storage, define volume mappings. Use the `${HOMELAB_DOCKER_PATH}` variable for server-side path consistency.
        ```dockercompose
        # /workspace/docker-compose.override.yml
        services:
          # ... other services ...
          newapp:
            ports:
              - "${newapp_port:-300X}:<container_internal_port>/tcp"
            volumes: # Optional, if needed
              - "${HOMELAB_DOCKER_PATH}/newapp/data:/path/inside/container:rw"
        ```

4.  **Define Ansible Variables for the App's Port:**
    *   This allows for different port configurations for local and server environments.
    *   **`ansible/group_vars/all.yml`:** Add a default port for the new app.
        ```yaml
        # ansible/group_vars/all.yml
        # ...
        newapp_port: 300X # Default port
        ```
    *   **`ansible/host_vars/localhost.yml`:** (Optional) Override for local deployment.
        ```yaml
        # ansible/host_vars/localhost.yml
        # ...
        newapp_port: 300X
        ```
    *   **`ansible/host_vars/homelab-server.yml`:** (Optional) Override for server deployment.
        ```yaml
        # ansible/host_vars/homelab-server.yml
        # ...
        newapp_port: 300X
        ```

5.  **Add the New Port Variable to `.env.j2` Template:**
    *   Edit `/workspace/ansible/roles/docker-compose/templates/.env.j2`.
    *   This ensures Ansible generates the `.env` file with the correct port variable for Docker Compose to use.
        ```bash
        # /workspace/ansible/roles/docker-compose/templates/.env.j2
        # ...
        newapp_port={{ newapp_port }}
        ```

6.  **Add UFW Rule (for Server Deployment):**
    *   Edit `/workspace/ansible/roles/ufw/tasks/main.yml`.
    *   Add a task to allow traffic on the new app's host port.
        ```yaml
        # /workspace/ansible/roles/ufw/tasks/main.yml
        # ...
        - name: Allow NewApp UI
          community.general.ufw:
            rule: allow
            port: "{{ newapp_port }}"
            proto: tcp
            comment: "Allow NewApp UI (Port {{ newapp_port }})"
          when: newapp_port is defined
        ```

7.  **(Optional) Add to Homepage Configuration:**
    *   Edit `/workspace/homepage/config/bookmarks.yaml`:
        *   Add a bookmark entry.
        *   **Note on `href`:** Since Homepage configuration files are not currently templated by Ansible for dynamic IP/port substitution, you'll need to use a fixed IP (`localhost` or your server's IP like `192.168.1.92`) and the actual port number.
            ```yaml
            # /workspace/homepage/config/bookmarks.yaml
            # ...
            - My New Apps: # Or any other relevant group
                - NewApp:
                    - abbr: NA
                      href: http://<IP_OR_LOCALHOST>:<actual_newapp_port_number> # e.g., http://localhost:300X or http://192.168.1.92:300X
                      icon: newapp.png # Add newapp.png to /workspace/homepage/config/icons/
            ```
        *   You'll need to decide if the link should point to `localhost` (for local access) or the server IP. If you access Homepage from both environments, one set of links might not work correctly without further customization or templating.
    *   Edit `/workspace/homepage/config/services.yaml` (if adding a widget):
        *   Follow Homepage documentation to add a service widget if applicable. Similar considerations for URLs apply.

8.  **Create App Directory and Commit:**
    *   Ensure the app's directory (e.g., `/workspace/newapp/`) is created.
    *   Commit all your changes to Git:
        ```bash
        git add .
        git commit -m "feat: Add newapp application"
        git push
        ```

9.  **Deploy and Test:**
    *   For local deployment: `./deploy.sh`
    *   For server deployment: `./deploy.sh --server`
    *   Verify the application is running (`docker ps`), accessible on its port, and any persistent data is correctly mapped. Check `docker logs newapp` for issues.

**Important Considerations:**
*   **Icons:** For Homepage bookmarks/widgets, place corresponding icon files (e.g., `newapp.png`) in `/workspace/homepage/config/icons/`.
*   **Persistent Data:** Carefully consider the application's data persistence needs and configure volumes appropriately.
*   **Environment Variables:** If the new app requires specific environment variables beyond ports, define them in `/workspace/docker-compose.override.yml` under the service's `environment:` section. These can also be sourced from the `.env` file if needed.

---

### Enjoy your fully automated Homelab!

```bash
# Local test:
./deploy.sh

# Remote deploy:
./deploy.sh --server
```
