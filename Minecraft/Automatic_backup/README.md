# 🧰 Minecraft Fabric Server Backup System

![Backup Status](https://img.shields.io/badge/backups-automated-brightgreen)
![Sync](https://img.shields.io/badge/google--drive-synced-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Automated weekly backups for Minecraft Fabric servers running in Docker. Supports multiple worlds, backup rotation, and Google Drive uploads via `rclone`.

---

## 💡 Features

- ✅ Weekly scheduled backups
- ✅ Compresses and rotates backups (keeps 3)
- ✅ Syncs to Google Drive
- ✅ Cron-compatible and headless-server friendly
- ✅ Easily extendable for multiple worlds

---

## 🌍 Worlds Configuration

Each world has:
- A named backup script (`backup_<world>.sh`)
- A target directory for world data
- Its own cron schedule

| World Name   | Path to World                               | Backup Path                                 | Google Drive Folder                        |
|--------------|----------------------------------------------|---------------------------------------------|---------------------------------------------|
| test_world2  | `/home/ulen4/minecraft_servers/New/test_world2/world` | `/home/ulen4/minecraft_backups/test_world2` | `gdrive:minecraft_backups/test_world2`      |
| (Add more...)| ...                                          | ...                                         | ...                                         |

---

## 🚀 Setup

### 1. Install `rclone` & Authenticate

```bash
sudo apt install rclone -y
rclone config
```

- Choose `n` for auto config (headless mode)
- Open URL in local browser, authorize, paste token
- Name remote `gdrive`

---

### 2. Create Backup Script (per world)

```bash
#!/bin/bash
# Save as backup_<world>.sh

WORLD_NAME="test_world2"
WORLD_DIR="/home/ulen4/minecraft_servers/New/$WORLD_NAME/world"
BACKUP_DIR="/home/ulen4/minecraft_backups/$WORLD_NAME"
TIMESTAMP=$(date +'%Y-%m-%d')
BACKUP_NAME="${WORLD_NAME}_$TIMESTAMP.tar.gz"
REMOTE_NAME="gdrive"
REMOTE_PATH="minecraft_backups/$WORLD_NAME"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$WORLD_DIR" .
cd "$BACKUP_DIR"
ls -1t ${WORLD_NAME}_*.tar.gz | tail -n +4 | xargs -d '\n' -r rm --
rclone copy "$BACKUP_DIR/$BACKUP_NAME" "$REMOTE_NAME:$REMOTE_PATH"
rclone ls "$REMOTE_NAME:$REMOTE_PATH" | awk '{print $2}' | sort -r | tail -n +4 | while read -r file; do
  rclone delete "$REMOTE_NAME:$REMOTE_PATH/$file"
done
```

---

### 3. Cron Schedule

```cron
0 3 * * 0 TZ=America/Toronto /home/ulen4/scripts/backup_test_world2.sh >> /home/ulen4/scripts/backup_test_world2.log 2>&1
```

---

### ✅ Test

```bash
/home/ulen4/scripts/backup_test_world2.sh
```

Check backups:
- Local: `/home/ulen4/minecraft_backups/test_world2`
- Drive: `gdrive:minecraft_backups/test_world2`

---

