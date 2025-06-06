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

---

### 📄 Step 4 Understanding the `docker-compose.yml`

The `docker-compose.yml` file is the recipe for your server. Here’s a quick breakdown of the important parts:

* **`variables`**: The **docker-compose** file in this repo takes all the most important variables from the `.env` configuration file.
* **`image: itzg/minecraft-server`**: This tells Docker what image to use.
* **`ports`**: This maps the server's port inside the container to a port on your host machine, allowing players to connect.
* **`volumes`**: This is the most critical part for data safety. It links a folder on your server (e.g., `./minecraft-data`) to a folder inside the container. This means your world, and configs are saved on your machine, not just inside the temporary container.

The [`docker-compose.yaml`](./docker-compose.yaml) file in this repo serves as a template that has all the necesary configuration that  I wanted. It should serve for most modded servers, one important note is that I share all the mods across my minecraft server so I have all the **docker-compose** files linked with the same **mods** folder to update all of them at the same time. I get all my mods from **[`Modrinth`](https://modrinth.com/)**

---

### ⚙️ Step 5: Configure Your Server (`.env` file)

Before you launch the server, you need to modify the configuration file named `config.env` in the same directory as your `docker-compose.yml`. You can use the template [`.env`](./.env) in this repository as a guide. This file stores all your custom settings for both the container and the minecraft servers, like ports to use, the gamemode, seed, among others.

---

## Step 6: 🚀 Running the Server

Now everything should be ready. Navigate to the project folder and run:

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

---


## 📁 Files in This Folder

| File | Description                               |
|--------------|----------------------------------------------|
| docker-compose.yml	 | Main file to spin up the Minecraft server |
| server.properties |Minecraft server configuration            |
| notes.md | Additional notes or to-do items                   |

---

## 💡 Tips

- 🧠 Always back up your world before rebuilding or updating containers
- ⚙️ Use .env files to customize ports, version, and variables
- 💾 Use volumes in docker-compose.yml to persist world data

---

## Important links
- 🐳 Docker documentation https://docs.docker.com/manuals/
- Mondrinth mods https://modrinth.com/
