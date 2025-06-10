# 🛠 Troubleshooting Guide

This folder contains notes, commands, and solutions to help you debug common issues with the Minecraft server setup, including Docker, Fabric mods, Geyser/Floodgate, backups, and networking.

---

## 📁 Folder Overview

| File                     | Purpose                                         |
|--------------------------|-------------------------------------------------|
| `docker_issues.md`       | Fixes for Docker container & volume issues      |
| `mod_crashes.md`         | Debugging Fabric mod compatibility & crashes    |
| `geyser_floodgate.md`    | Fixes for Bedrock connectivity issues           |
| `backup_failures.md`     | Common causes for failed backups via rclone     |
| `tailscale_networking.md`| Tailscale-related issues and DNS visibility     |
| `general_tips.md`        | Logs, permissions, and useful diagnostics       |

---

## 🧪 Quick Checklist

Before diving deep into logs, try these first:

- ✅ Is the server **running**?  
  Run:
  ```
  docker compose ps
  ```

- ✅ Are logs showing anything useful?  
  Run:
  ```docker compose logs -f
  ```
  Or for a specific service:  
  ```
  docker compose logs -f <service_name>
  ```

- ✅ Are you using the **correct mod versions** (Fabric, Minecraft, dependencies)?

- ✅ Is the world path or backup path **correct and writable**?

- ✅ Are **volumes mounted correctly** in Docker?

- ✅ Is `rclone` working?  
  Try: `rclone ls gdrive:` or `rclone config show`

- ✅ Is `crontab` actually scheduled?  
  Run: `crontab -l`

---

## 🧠 Common Commands

### View Docker Service Logs

```
docker compose logs -f
```

### Restart the Server
```
docker compose down
docker compose up -d
```

Check Docker Service Status
```
sudo systemctl status docker
```
Rebuild the Docker Container
```
docker compose build
```

---


## 📚 Need Help?

If you’re stuck:

- Search in logs for keywords like:
error, exception, failed, missing, permission, bind

- Check version mismatches in:
 - mods/
 - docker-compose.yml
 - config/

Review crash reports in:

```
minecraft_servers/<server_name>/crash-reports/
```

---
