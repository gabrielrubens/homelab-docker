# *Arr Stack & Jellyfin Setup Guide

This guide provides step-by-step instructions for configuring your newly deployed media stack. All services are running in Docker and can communicate with each other using their service names (e.g., `qbittorrent`, `sonarr`).

**IMPORTANT: Understanding Docker Paths**
Each application runs in its own isolated container. We use volume mappings in Docker to create a "portal" from a path inside the container to a path on your server.

Example: `- /srv/homelab-docker/media/tv:/tv`
- **Inside the Sonarr app, you must use the container path: `/tv`**
- You will **not** see `/srv/` or `/homelab-docker/` inside the app's file browser. You must go directly to the mapped path (e.g., `/tv`, `/movies`, `/downloads`).

---

### **Configuration Order**

1.  **qBittorrent** (The Downloader)
2.  **Prowlarr** (The Indexer Manager)
3.  **Sonarr / Radarr / Lidarr** (The Media Managers)
4.  **Bazarr** (The Subtitle Manager)
5.  **Jellyfin** (The Media Server)
6.  **Jellyseerr** (The Request Manager)

---

### **Step 1: Configure qBittorrent**

1.  **Open qBittorrent:** Navigate to `http://192.168.1.92:8080`.
2.  **Find Temporary Password:** The application generates a random password on first start. To find it, run this command on your server's terminal:
    ```bash
    sudo docker logs qbittorrent
    ```
    Look for a line like: `The WebUI administrator password ... is provided for this session: <your_temporary_password>`
3.  **Login:**
    *   **Username:** `admin`
    *   **Password:** `<your_temporary_password>`
4.  **Set Your Own Password:** Immediately go to **Tools -> Options... -> Web UI** and set a permanent password.
5.  **Set Save Path:**
    *   Go to **Tools -> Options... -> Downloads**.
    *   In "Default Save Path", enter the **exact container path**:
        ```
        /downloads
        ```
    *   Check "Keep incomplete torrents in:" and enter:
        ```
        /downloads/incomplete
        ```
    *   Click **Save**.

---

### **Step 2: Configure Prowlarr (Indexer Manager)**

Prowlarr manages your indexers and syncs them to your other *Arr apps.

1.  **Open Prowlarr:** Navigate to `http://192.168.1.92:9696`.
2.  **Add Your Indexers:**
    *   Go to the **Indexers** tab.
    *   Click the `+` button and add all of your preferred torrent and Usenet indexers.
3.  **Connect *Arr Apps:**
    *   Go to **Settings -> Apps**.
    *   Click the `+` button to add an application.
    *   Select **Sonarr**.
    *   Fill in the details:
        *   **Name:** Sonarr
        *   **Sync Level:** `Add and Remove`
        *   **Prowlarr Server:** `http://prowlarr:9696`
        *   **Sonarr Server:** `http://sonarr:8989`
        *   **API Key:** Find this in Sonarr's web UI under **Settings -> General**.
    *   Click **Test**. It should succeed. Click **Save**.
    *   Repeat this process for **Radarr** (`http://radarr:7878`) and **Lidarr** (`http://lidarr:8686`).

---

### **Step 3: Configure Sonarr (TV Shows)**

1.  **Open Sonarr:** Navigate to `http://192.168.1.92:8989`.
2.  **Verify Indexers:** Go to **Settings -> Indexers**. You should see the indexers you added in Prowlarr. They will be managed by Prowlarr, so you don't need to add them here manually.
3.  **Add a Root Folder:**
    *   Go to **Settings -> Media Management**.
    *   Click the `+` icon to add a root folder.
    *   For the path, enter the **exact container path** for your TV shows:
        ```
        /tv
        ```
    *   Click **Ok**.
4.  **Connect Download Client:**
    *   Go to **Settings -> Download Clients**.
    *   Click `+`, find and select **qBittorrent**.
    *   Fill in the details:
        *   **Name:** qBittorrent
        *   **Host:** `qbittorrent`
        *   **Port:** `8080`
        *   **Username/Password:** The new permanent password you set in qBittorrent.
    *   Click **Test**. It should succeed. Click **Save**.
5.  You can now start adding TV shows.

---

### **Step 4: Configure Radarr (Movies) & Lidarr (Music)**

The process is identical to Sonarr. Verify your Prowlarr indexers are present, set up the root folder, and connect the qBittorrent download client.

*   **Radarr (`http://192.168.1.92:7878`):**
    *   **Root Folder Path:** `/movies`
    *   Connect qBittorrent as the download client.

*   **Lidarr (`http://192.168.1.92:8686`):**
    *   **Root Folder Path:** `/music`
    *   Connect qBittorrent as the download client.

---

### **Step 5: Configure Apprise Notifications**

Apprise is used to handle all notifications from the *Arr stack to services like Telegram, Discord, etc. You will add Apprise as a connection in each app.

1.  **In Sonarr/Radarr/Lidarr/Bazarr:**
    *   Navigate to **Settings -> Connect**.
    *   Click the `+` button to add a new connection.
    *   Find and select **Apprise** from the list.
2.  **Configure the Apprise Connection:**
    *   **Name:** `Apprise` (or any name you prefer).
    *   **Hostname:** `apprise` (this is the Docker service name).
    *   **Port:** `8000`
    *   **URL(s) / Key**: In this field, you only need to provide the configuration key. Enter:
        ```
        apprise
        ```
3.  **Test and Save:**
    *   Click the **Test** button. You should see a "Test successful" message.
    *   Click **Save**.

Repeat these steps for each *Arr application to centralize your notifications.

---

### **Step 6: Configure Jellyfin (Media Server)**

1.  **Open Jellyfin:** `http://192.168.1.92:8096` and complete the setup wizard.
2.  **Add Media Libraries:**
    *   From the dashboard, click **Add Media Library**.
    *   **For TV Shows:**
        *   Content Type: `Shows`
        *   Click `+` to add a folder and enter the **exact container path**: `/data/tvshows`
    *   **For Movies:**
        *   Content Type: `Movies`
        *   Folder Path: `/data/movies`
    *   **For Music:**
        *   Content Type: `Music`
        *   Folder Path: `/data/music`

---

### **Step 7: Configure Jellyseerr (Requests)**

1.  **Open Jellyseerr:** `http://192.168.1.92:5055` and log in with your Jellyfin account.
2.  **Connect Services:**
    *   Go to **Settings -> Services**.
    *   Connect to Jellyfin, Sonarr, and Radarr using their service names (`jellyfin`, `sonarr`, `radarr`) and API keys.
    *   For Sonarr and Radarr, ensure the default paths are set correctly (e.g., `/tv` for Sonarr).
