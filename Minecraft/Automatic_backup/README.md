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
| server_name  | `/home/server_name/minecraft_servers/mc_servername` | `/home/server_name/minecraft_backups/mc_servername` | `gdrive:minecraft_backups/mc_servername`      |
| (Add more...)| ...                                          | ...                                         | ...                                         |

---

## 🚀 Setup

### 1. Install `rclone` & Authenticate

NOTE: to properly configure rclone in a headless Ubuntu server, you should already have it installed in a machine with access to a browser (like Windows).

To configure in Windows

### ✅ Easy Installer for Windows

Follow these steps to install `rclone` on Windows:

---

### 1. 📥 Download the rclone Installer

Visit the official site:  
👉 [https://rclone.org/downloads/](https://rclone.org/downloads/)

Download the version for your system:

- Most users should choose:  
  **`rclone-v*-windows-amd64.zip`** (for 64-bit systems)

---

### 2. 🗂 Extract the ZIP File

Extract the downloaded ZIP to a folder like:

```
C:\rclone
```

Inside you'll find:

- `rclone.exe`
- `README.txt`
- Additional files

---

### 3. ⚙️ (Optional) Add rclone to your System PATH

So you can run `rclone` from any terminal window:

1. Press `Windows Key` and search **Environment Variables**
2. Open **"Edit the system environment variables"**
3. Click **Environment Variables**
4. Under **System variables**, find and select `Path`, then click **Edit**
5. Click **New** and add:
   ```
   C:\rclone
   ```
6. Click **OK → OK → OK** to save

---

### 4. ✅ Test the Installation

Open **Command Prompt** or **PowerShell** and run:

```bash
rclone version
```

You should see version details like:

```
rclone v1.66.0
- os/version: windows
- os/arch: amd64
...
```

You're ready to go!

### ✅ Easy Installer for Ubuntu headless

```bash
sudo apt install rclone -y
rclone config
```

- Choose `n` for auto config (headless mode)
- Follow the instruction to get the token from another authentified machine.
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

