# 🛠️ Creating My Own Minecraft Server

This repository contains all files and documentation related to running personal Minecraft servers using Docker. It includes Docker Compose configurations, setup guides for running Minecraft on a Linux machine, and instructions for managing server containers and interacting with the server console.



---

## 🚀 Getting Started

These instructions will help you set up the project on a Linux machine (in my case Ubuntu Headless) for development or personal gameplay.

### 🐳 Installing Docker and Docker Compose on Linux

```
sudo apt update -y
sudo apt install docker-compose -y
```

### 🧱 Launching the Minecraft Server

```
sudo docker compose up -d
```

If you want to run Docker without sudo, follow this guide:
👉 https://docs.docker.com/engine/install/linux-postinstall/

### 🔧 Useful Docker Commands

#### Create and start container (force reinstallation if needed)
`docker compose up -d --force-recreate`

#### Stop the container
```
docker stop server_name
```

#### Start the container
```
docker start server_name
```

#### Restart the container
```
docker restart server_name
```

#### Remove the container
```
docker rm server_name
```

#### List all containers
```
docker ps
```

#### Create a Docker network
```
docker network create my_network
```

#### List available Docker images
```
docker images
```

#### Remove a specific image
```
docker rmi image_name
```

### 📦 Deployment

All Minecraft servers are deployed using docker compose on an Ubuntu server.

Servers use Fabric as the primary mod loader (previously used Spigot).

Portainer is recommended for:
- Accessing the Minecraft server console
- Viewing container logs easily through a UI

### 🎮 Sending Commands to the Server Console
From the host machine, you can interact with the Minecraft server inside Docker using:

```
docker exec -i server_name rcon-cli
```

Example: granting operator privileges to a player
```
docker exec -i mc_servername rcon-cli /op player_name
```

### 🔗 Useful Links
#### 🧩 Download Minecraft mods:
- https://modrinth.com/

#### 🌉 Geyser/Floodgate (Java <=> Bedrock compatibility):
- https://geysermc.org/

#### ✨ Complementary Shaders for enhanced visuals:
- https://www.complementary.dev/shaders/

#### 🎨 Resource Packs and Texture Packs:
- https://www.curseforge.com/minecraft/search?class=texture-packs
