# Minecraft Server Setup with Docker, Mods, Remote Access & Backups

![Project Status](https://img.shields.io/badge/status-learning-informational)
![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)
![Fabric](https://img.shields.io/badge/mod-loader-fabric-blueviolet)
![Backups](https://img.shields.io/badge/backup-automated-success)
![Remote Access](https://img.shields.io/badge/remote%20access-tailscale-blue?logo=tailscale)
![Last Updated](https://img.shields.io/github/last-commit/ulen7/Minecraft_Ulen)
![License](https://img.shields.io/badge/license-MIT-green)

Welcome to my Minecraft server setup project! I started this as a way to host a fun and safe server for my kid, and along the way, I took it as an opportunity to learn and improve my skills in Docker, Linux, modding, automation, and remote networking.

This repo documents the full journey — from a basic server to a more advanced setup with Fabric mods, automated backups, and remote access using Tailscale.

I’m still improving and tweaking things, and I’ve structured everything so it’s easy to follow and build on. Eventually, I plan to share this on the community for feedback and to help others.

---

## 🗂 Folder Structure

| Folder | Description |
|--------|-------------|
| [`docker/`](./docker) | Docker Compose setup to run the server. Includes config files and notes. |
| [`mods/`](./mods) | Guides on adding Fabric mods, example mod list, and tips. |
| [`tailscale/`](./tailscale) | Setup guide for remote access via Tailscale VPN. |
| [`backups/`](./backups) | Scripts and configuration for automatic backups with Google Drive using `rclone`. |
| [`troubleshooting/`](./troubleshooting) | Notes on common issues and fixes I’ve encountered. |

---

## 💡 Goals

- 🧠 Learn by doing (Docker, automation, modding)
- ⚙️ Build a stable Minecraft server setup for my kid
- ☁️ Enable automatic offsite backups
- 🔐 Allow secure remote access using Tailscale
- 🗃️ Document everything in case others want to follow the same path

---

## ✅ Features

- Fabric mod support via Docker
- Remote access using Tailscale
- Automated weekly backups uploaded to Google Drive
- Clean folder structure for easy maintenance and learning

---

## ⚠️ Disclaimer

I'm not an expert — this is a personal learning project. Use this repo at your own risk and feel free to fork or adapt it to your own needs.

---

## 📬 Future Plans

- Add auto mod version updates (work in progress)
- Add testing environments
- Improve the automation aspect to create new servers

---
