# Minecraft Server Backup Automation (Fabric + Docker + rclone)

This repo includes a Bash-based backup system for Dockerized Minecraft Fabric servers, with automatic rotation and Google Drive sync via `rclone`.

---

## 🛠 Requirements

- Docker-based Minecraft server (e.g., itzg/minecraft-server)
- World stored on host (volume mount)
- `rclone` installed and configured for Google Drive
- `cron` enabled (default on most Linux systems)
- REPLACE server_name with the name of your server

---

## 🌍 Supported Worlds

You can duplicate the script per world. Example setup:

- `/home/server_name/minecraft_servers/New/test_world1/world`
- `/home/server_name/minecraft_servers/New/test_world2/world`

Backups are stored separately per world.

---

## 📂 Backup Details

- Weekly backups every **Sunday @ 3 AM (Toronto time)**
- Backups stored at:
  ```
  /home/server_name/minecraft_backups/<world_name>
  ```
- Uploaded to Google Drive:  
  `gdrive:minecraft_backups/<world_name>`
- **Only latest 3 backups are kept** (locally + on Drive)

---

## 📜 Script Template (`backup_<world>.sh`)

Replace `<world>` and `<mc_servername>` with your actual world name:

```bash
#!/bin/bash

WORLD_NAME="mc_servername"
WORLD_DIR="/home/serve_name/minecraft_servers/New/$WORLD_NAME/world"
BACKUP_DIR="/home/serve_name/minecraft_backups/$WORLD_NAME"
TIMESTAMP=$(date +'%Y-%m-%d')
BACKUP_NAME="${WORLD_NAME}_$TIMESTAMP.tar.gz"
REMOTE_NAME="gdrive"
REMOTE_PATH="minecraft_backups/$WORLD_NAME"

mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$WORLD_DIR" .

cd "$BACKUP_DIR"
ls -1t ${WORLD_NAME}_*.tar.gz | tail -n +4 | xargs -d '\n' -r rm --

rclone copy "$BACKUP_DIR/$BACKUP_NAME" "$REMOTE_NAME:$REMOTE_PATH"

REMOTE_BACKUPS=$(rclone ls "$REMOTE_NAME:$REMOTE_PATH" | awk '{print $2}' | sort -r)
echo "$REMOTE_BACKUPS" | tail -n +4 | while read -r file; do
  rclone delete "$REMOTE_NAME:$REMOTE_PATH/$file"
done
```

Make executable:

Note that in some ocasions you may need to run the chmod command as root (sudo chmod...)

```bash
chmod +x /home/ulen4/scripts/backup_<world>.sh
```

---

## ⏲ Cron Job Template

Open crontab:

```bash
crontab -e
```

Add for each world:

```cron
0 3 * * 0 TZ=America/Toronto /home/serve_name/scripts/backup_<world>.sh >> /home/server_name/scripts/backup_<world>.log 2>&1
```

---

## 🧪 Manual Test

While in the directory of the bash file

```bash
./backup_<world>.sh
```

---

## 🔐 rclone Headless Setup (Summary)

IMPORTANT: if you are running your server in a headless Ubuntu server as I am,  you should first run rclone in a computer with a browser (like any windows machine).

1. Run `rclone config` on server
2. Choose `drive`, say `n` to auto config
3. Open auth URL on desktop browser, approve, paste code
4. Name the remote `gdrive` (or any)
5. Done! Test with:

```bash
rclone ls gdrive:
```

---
