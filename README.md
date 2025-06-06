# Minecraft Server Setup with Docker, Mods, Remote Access & Backups

![Project Status](https://img.shields.io/badge/status-learning-informational)
![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)
![Minecraft](https://img.shields.io/badge/Minecraft%20mod%20loader-fabric-blueviolet)
![Backups](https://img.shields.io/badge/backup-automated-success)
![Remote Access](https://img.shields.io/badge/remote%20access-tailscale-blue?logo=tailscale)
![Last Updated](https://img.shields.io/github/last-commit/ulen7/Minecraft_Ulen)
![License](https://img.shields.io/badge/license-MIT-green)

Welcome to my Minecraft server setup project! I started this as a way to host a fun and safe server for my kid, and along the way, I took it as an opportunity to learn and improve my skills in Docker, Linux, modding, automation, and remote networking.

This repository documents my journey in setting up a personal, modded Minecraft server for my family. What started as a simple server has become a fun learning project involving **Docker**, **Fabric mods**, **Tailscale** for remote access, and **automated backups** to Google Drive.

My goal is to continuously improve this setup, learn as I go, and create a comprehensive guide for others who might want to do the same.

---
### ✨ Core Features

* **Containerized with Docker:** Easy to manage, deploy, and replicate the server environment.
* **Modded with Fabric:** Running a lightweight, moddable server version.
* **Secure Remote Access:** Using [Tailscale](https://tailscale.com/) to create a secure network for remote play.
* **Automated Backups:** Nightly backups of the world data are automatically created and uploaded to Google Drive, so we never lose our progress.
---

### 🗂 Folder Structure

| Folder | Description |
|--------|-------------|
| [`Docker/`](./Docker) | Docker Compose setup to run the server. Includes config files and notes. |
| [`Mods/`](./Mods) | Guides on adding Fabric mods, example mod list, and tips. |
| [`Tailscale/`](./Tailscale) | Setup guide for remote access via Tailscale VPN. |
| [`Backups/`](./Backups) | Scripts and configuration for automatic backups with Google Drive using `rclone`. |
| [`Troubleshooting/`](./Troubleshooting) | Notes on common issues and fixes I’ve encountered. |

---

### 💡 Goals

- 🧠 Learn by doing (Docker, automation, modding)
- ⚙️ Build a stable Minecraft server setup for my kid
- ☁️ Enable automatic offsite backups
- 🔐 Allow secure remote access using Tailscale
- 🗃️ Document everything in case others want to follow the same path

---

### ⚠️ Disclaimer

I'm not an expert — this is a personal learning project. Use this repo at your own risk and feel free to fork or adapt it to your own needs.

---

### 💡 Future Plans

This project is always evolving. Here are some things I'm thinking about next:

- [ ] Exploring more performance-enhancing mods.
- [ ] Setting up a server monitoring dashboard (e.g., with Grafana).
- [ ] Create a one-click script to install everything easier for begginers.

---

### 🤝 Contributing

This is a personal project, but I'm open to suggestions and improvements! If you have an idea, feel free to fork the repository and submit a pull request.
