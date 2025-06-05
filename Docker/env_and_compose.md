# ⚙️ Environment Variables & Docker Compose Example

This section explains how to use a `.env` file to simplify Docker Compose configuration and maintain flexibility when changing server versions, ports, or file paths.

---

## 📄 What is a `.env` file?

A `.env` file lets you define key-value pairs that can be referenced inside your `docker-compose.yml`. This keeps sensitive or editable values outside the compose file and improves reusability.

**Example `.env` file:**

```env
# Minecraft server settings
SERVER_NAME=minecraft_fabric
VERSION=1.20.1
PORT=25565

# Paths (mounted from host)
WORLD_PATH=/home/ulen4/minecraft_servers/${SERVER_NAME}/world
MODS_PATH=/home/ulen4/minecraft_servers/${SERVER_NAME}/mods
CONFIG_PATH=/home/ulen4/minecraft_servers/${SERVER_NAME}/config

# EULA (must be true to run)
EULA=true

# Memory limits
MEM_MIN=1G
MEM_MAX=3G
