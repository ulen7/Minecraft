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
