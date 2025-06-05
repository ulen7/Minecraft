# 🐳 Docker Setup for Minecraft Server

![Docker](https://img.shields.io/badge/docker-setup-blue)
![Minecraft](https://img.shields.io/badge/minecraft-server-green)
![Fabric](https://img.shields.io/badge/mod%20loader-fabric-blueviolet)

This folder contains everything related to running the Minecraft server using Docker.

---

## 📦 Step 1: Install Docker

For most systems, you can install Docker using the official script:

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

Or use your OS package manager:

### Ubuntu/Debian:

```
sudo apt update
sudo apt install docker.io
```

---

## ▶️ Step 2: Enable and Start Docker

```
sudo systemctl enable docker
sudo systemctl start docker
```

## 📦 Step 3: Install Docker Compose

Recent Docker versions include Compose as a plugin:

```
docker compose version
```

If not installed:

```
sudo apt install docker-compose
```

---

### 🚀 Running the Server

Navigate to the project folder and run:

```
docker compose up -d
```
⚠️Important : Follow the steps here to use docker as non-root user if needed : https://docs.docker.com/engine/install/linux-postinstall/

To stop the server:
```
docker compose down
```

To view logs:
```
docker compose logs -f
```

---

### 🔁 Updating the Container

Rebuild the container if you made changes to the Dockerfile:
```
docker compose build
```

Or pull a newer version of the base image:
```
docker compose pull
```

---

### 🛠 Troubleshooting

#### 1. Check Docker service status
```
systemctl status docker
```

#### 2. Check container logs
```
docker compose logs -f
```

Or for a specific service:
```
docker compose logs -f docker_container_name
```

#### 3. Restart everything

```
docker compose down
docker compose up -d
```

#### 4. Remove unused containers, networks, and images

⚠️ This removes all unused containers and volumes!
```
docker system prune -a
```
## 📁 Files in This Folder

| File | Description                               |
|--------------|----------------------------------------------|
| docker-compose.yml	 | Main file to spin up the Minecraft server |
| server.properties |Minecraft server configuration            |
| notes.md | Additional notes or to-do items                   |



## 💡 Tips

- 🧠 Always back up your world before rebuilding or updating containers
- ⚙️ Use .env files to customize ports, version, and variables
- 💾 Use volumes in docker-compose.yml to persist world data

