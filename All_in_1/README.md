# 🛠️ Minecraft Docker Server Setup Script

An interactive Bash script that helps you configure and deploy a fully customized Minecraft server using Docker Compose — with support for **Java**, **Bedrock (via Geyser)**, **Fabric mods**, **Tailscale VPN**, **automatic backups to Google Drive**, and optional **RCON web interface**.

---

## 🚀 Features

- 🧱 Supports **Vanilla**, **Fabric**, **Spigot**, and **Paper**
- 🌉 Optional **Geyser** for Bedrock Edition cross-play
- 📦 **Fabric mod installation** via Modrinth (with future manual mod support)
- 🔒 **Tailscale VPN** support for remote play on a private network
- ☁️ **Automated backups** to Google Drive via `rclone`, with rotation and logging
- 🖥️ Optional **RCON Web UI** support for remote server control
- 💾 Fully interactive and **recoverable setup**
- 📂 Generates `docker-compose.yml`, `backup.sh`, and startup instructions
- ⌛ Optional progress bar and post-launch configuration (e.g., auto-patching Geyser)

---

## 📦 Requirements

- **Bash**
- **Docker** + **Docker Compose V2**
- Optional:
  - `rclone` (for cloud backups)
  - `sudo` access (for rclone installation)
  - Tailscale account & auth key

---

## 🧰 How It Works

1. Clone or download the script.
2. Run it in your terminal:
   ```bash
   ./setup-mc-server.sh

