# Minecraft Server Backup Automation

![Backup Status](https://img.shields.io/badge/backups-automated-brightgreen)
![Sync](https://img.shields.io/badge/google--drive-synced-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

Automated weekly backups for Minecraft Fabric servers running in Docker.

Supports multiple worlds, backup rotation, and Google Drive syncing via [`rclone`](https://rclone.org/).

---

## Features

- ✅ Weekly scheduled backups
- ✅ Compresses and rotates backups (keeps 3)
- ✅ Syncs to Google Drive
- ✅ Cron-compatible and headless-server friendly
- ✅ Easily extendable for multiple worlds

---

## Requirements

- World stored on host (volume mount)
- `rclone` installed and configured for Google Drive
- `cron` enabled (default on most Linux systems)

---

## 🌍 Worlds Configuration

Each world has:
- A named backup script (`backup_<world>.sh`)
- A target directory for world data
- Its own cron schedule

---

## Setup

### ☁️ 1. Install `rclone`

To properly configure `rclone` in a headless Ubuntu server, you should already have it installed in a machine with access to a browser (like Windows).

### 1.1 To configure in Windows

This guide walks you through installing and configuring `rclone` to connect a **Windoes Machine** to your **Google Drive** account.

---

##### 1.1.1 Download the rclone Installer

Visit the official site:  
👉 [https://rclone.org/downloads/](https://rclone.org/downloads/)

Download the version for your system:

- Most users should choose:  
  **`rclone-v*-windows-amd64.zip`** (for 64-bit systems)

---

##### 1.1.2 Extract the ZIP File

Extract the downloaded ZIP to a folder like:

```
C:\rclone
```

Inside you'll find:

- `rclone.exe`
- `README.txt`
- Additional files

---

#### 1.1.3 (Optional) Add rclone to your System PATH

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

#### 1.1.4 the Installation

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

---

### 1.2 To configure in Ubuntu Headless

This guide walks you through installing and configuring `rclone` to connect a **headless Ubuntu server** to your **Google Drive** account.

---

#### 1.2.1: Install rclone

Run the following in your terminal:

```bash
sudo apt update
sudo apt install rclone -y
```

To verify the installation:

```bash
rclone version
```

---

#### 1.2.2: Configure Google Drive (Headless Auth)

Because the server is headless (no browser), follow this approach:

```bash
rclone config
```

1. Choose: `n` → *New remote*
2. Name the remote (e.g., `gdrive`)
3. Choose storage:  
   ```
   19 / Google Drive
      \ "drive"
   ```
4. When asked **"Use auto config?"**, type: `n`
5. rclone will display a command to paste in a machine with rclone installed and browser available and a request to input a  :
   ```
   rclone ********
   ```

---

#### 1.2.3: Authorize via Browser

1. Copy the command from the SSH terminal
2. Paste it into your Windows Terminal on your **local computer** with rclone installed
3. Follow the instructions
4. Log in with the **Google Drive account**
5. Allow access and copy the verification code
6. Paste the code back into your SSH session

---

#### 1.2.4: Finalize Config

- Choose defaults for team drive unless you're using one
- Once done, `rclone` will save the config to `~/.config/rclone/rclone.conf`

Test your setup:

```bash
rclone ls gdrive:
```

If you see no errors or some files listed — you're connected!

---

## Example Usage

List Google Drive contents:

```bash
rclone ls gdrive:
```

Copy a local file to Drive:

```bash
rclone copy ~/test.txt gdrive:/my-folder
```

---

## 🧩 Notes

- Your authentication token is saved and reused — no need to reauthenticate frequently
- You can manage multiple remotes with `rclone config`
- Works great with backup automation scripts and cron jobs

---

### 2. Create Backup Script (per world)

```bash
#!/bin/bash
# Save as backup_<mc_servername>.sh


# === Configuration ===
WORLD_NAME="mc_servername"
WORLD_DIR="/home/server_name/minecraft_servers/New/$WORLD_NAME"
BACKUP_DIR="/home/server_name/minecraft_backups/$WORLD_NAME"
TIMESTAMP=$(date +'%Y-%m-%d')
BACKUP_NAME="${WORLD_NAME}_$TIMESTAMP.tar.gz"
REMOTE_NAME="gdrive"
REMOTE_PATH="minecraft_backups/$WORLD_NAME"

# === Create backup directory if it doesn't exist ===
mkdir -p "$BACKUP_DIR"

# === Create the backup ===
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$WORLD_DIR" .

# === Keep only 3 most recent backups ===
cd "$BACKUP_DIR"
ls -1t ${WORLD_NAME}_*.tar.gz | tail -n +4 | xargs -d '\n' -r rm --

# === Upload to Google Drive ===
rclone copy "$BACKUP_DIR/$BACKUP_NAME" "$REMOTE_NAME:$REMOTE_PATH"

# === Clean up older backups in Google Drive ===
rclone ls "$REMOTE_NAME:$REMOTE_PATH" | awk '{print $2}' | sort -r | tail -n +4 | while read -r file; do
  rclone delete "$REMOTE_NAME:$REMOTE_PATH/$file"
done
```

---


### Manual Test

While in the directory of the bash file

```bash
./backup_<mc_servername>.sh
```


Check backups:
- Local: `/home/server_name/minecraft_backups/mc_servername`
- Drive: `gdrive:minecraft_backups/mc_servername`

---

### 3. Cron Schedule

This project uses a `cron` job to automatically back up the Minecraft server world every **Sunday at 3:00 AM (Toronto time)**.

---

#### Step-by-Step Guide

##### 3.1 Open Crontab

Run the following command to edit your crontab:

```bash
crontab -e
```

If it's your first time using `crontab`, it may ask you to choose an editor (nano is usually easiest).

---

##### 3.2 Add the Cron Job

At the bottom of the file, add the following line:

```cron
0 3 * * 0 TZ=America/Toronto /home/ulen4/scripts/mc_backup.sh >> /home/ulen4/scripts/backup.log 2>&1
```

---

#### What This Does

##### 🔢 Schedule (`0 3 * * 0`)

| Field     | Value | Description                |
|-----------|-------|----------------------------|
| Minute    | `0`   | At minute `00`             |
| Hour      | `3`   | At hour `03` (3:00 AM)     |
| Day       | `*`   | Every day of the month     |
| Month     | `*`   | Every month                |
| Weekday   | `0`   | Sunday (`0` = Sunday)      |

This means the script runs **every Sunday at 3:00 AM**.

---

##### Timezone Override

```bash
TZ=America/Toronto
```

Ensures the task runs using the **America/Toronto timezone**, which is helpful if your server defaults to UTC or another timezone.

---

##### Script Path

```bash
/home/server_name/scripts/mc_backup.sh
```

Points to the shell script that handles:
- Compressing the world folder
- Uploading to Google Drive via `rclone`
- Rotating weekly backups (keeping only 3 latest)

> 🔒 Ensure the script has execute permissions:
```bash
chmod +x /home/server_name/scripts/mc_backup.sh
```

---

##### 🪵 Logging Output

```bash
>> /home/server_name/scripts/backup_mc_servername.log 2>&1
```

This appends both:
- **Standard output** (normal messages)
- **Standard error** (any errors)

to the same log file:

```bash
/home/server_name/scripts/backup_mc_servername.log
```

You can check this log to confirm backups ran successfully.

---


```cron
0 3 * * 0 TZ=America/Toronto /home/server_name/scripts/mc_backup.sh >> /home/server_name/scripts/mc_backup.log 2>&1
```

---

#### Cron Expression Validator

If you're unsure your `cron` schedule is correct, you can test it online using these tools:

- **[Crontab Guru](https://crontab.guru/)**  
  Simple and user-friendly — perfect for quick checks.

---

### Now you should be all set with your back-ups
