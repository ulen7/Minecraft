#!/bin/bash

# === 0. Constants & Defaults ===
# Default values and path setups
DEFAULT_SERVER_NAME="mc_server"
DEFAULT_VERSION="1.21.5"
DEFAULT_SERVER_TYPE="fabric"
DEFAULT_MEMORY="4G"
DEFAULT_JPORT="25565"
DEFAULT_BPORT="19132"
DEFAULT_FOLDER_BASE="$HOME/minecraft_servers"
DEFAULT_IMAGE="itzg/minecraft-server"
DEFAULT_USE_GEYSER="no"
DEFAULT_ENABLE_BACKUPS="no"
DEFAULT_ENABLE_TAILSCALE="no"
DEFAULT_Seed=""

# === 1. Intro & User Prompts ===
# Greeting:
echo "📝 Let's configure your Minecraft server..."
echo "You can use the default option by just pressing enter"

# === Server Name  ===
while true; do
  read -p "📛 Please enter a name for your server (letters, numbers, underscores, dashes). Leave blank for '${DEFAULT_SERVER_NAME}': " SERVER_NAME
  SERVER_NAME="${SERVER_NAME:-$DEFAULT_SERVER_NAME}"

  if [[ "$SERVER_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    break
  else
    echo "❌ Invalid server name. Please use only letters, numbers, underscores, or dashes."
  fi
done

# === Minecraft Version ===
while true; do
  read -p "🧱 Enter the Minecraft version (e.g., 1.20.4). Leave blank for default '${DEFAULT_MC_VERSION}': " MC_VERSION
  MC_VERSION="${MC_VERSION:-$DEFAULT_MC_VERSION}"

  if [[ "$MC_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    break
  else
    echo "❌ Invalid version format. Use format like '1.20.4' or '1.21'."
  fi
done

# === Server Type  ===
echo "🛠️ Select the type of Minecraft server to deploy:"
PS3="➡️ Choose 1–4 (default: ${DEFAULT_SERVER_TYPE}): "
options=("vanilla" "fabric" "spigot" "paper")

select opt in "${options[@]}"; do
  if [[ -z "$opt" ]]; then
    SERVER_TYPE="$DEFAULT_SERVER_TYPE"
    echo "ℹ️ Defaulting to: $SERVER_TYPE"
    break
  elif [[ " ${options[*]} " == *" $opt "* ]]; then
    SERVER_TYPE="$opt"
    break
  else
    echo "❌ Invalid option. Please choose a number between 1 and 4."
  fi
done

# ===  Memory Allocation ===
while true; do
  read -p "🧠 How much memory (in GB) should be allocated to the server? (2-32) [Default: $DEFAULT_MEMORY]: " MEMORY_ALLOCATION
  MEMORY_ALLOCATION="${MEMORY_ALLOCATION:-$DEFAULT_MEMORY}"
  if [[ "$MEMORY_ALLOCATION" =~ ^[0-9]+$ ]] && (( MEMORY_ALLOCATION >= 2 && MEMORY_ALLOCATION <= 32 )); then
    break
  else
    echo "❌ Please enter a number between 2 and 32."
  fi
done

# === Ports ===
while true; do
  read -p "🌐 Enter the port number for the server (1024–65535). Default is '${DEFAULT_PORT}': " MC_PORT
  MC_PORT="${MC_PORT:-$DEFAULT_PORT}"

  if [[ "$MC_PORT" =~ ^[0-9]+$ ]] && [ "$MC_PORT" -ge 1024 ] && [ "$MC_PORT" -le 65535 ]; then
    break
  else
    echo "❌ Invalid port. Please enter a number between 1024 and 65535."
  fi
done

# === Geyser/Floodgate ===
while true; do
  read -p "🌉 Do you want to enable Geyser/Floodgate support? (yes/no, default: ${DEFAULT_USE_GEYSER}): " USE_GEYSER
  USE_GEYSER="${USE_GEYSER:-$DEFAULT_USE_GEYSER}"

  case "$USE_GEYSER" in
    [yY]|[yY][eE][sS])
      USE_GEYSER="yes"
      break
      ;;
    [nN]|[nN][oO])
      USE_GEYSER="no"
      break
      ;;
    *)
      echo "❌ Please enter 'y' or 'n'."
      ;;
  esac
done

# === Automatic Backups ===
while true; do
  read -p "☁️  Enable Google Drive backups using rclone? (yes/no) [Default: $DEFAULT_ENABLE_RCLONE]: " ENABLE_RCLONE
  ENABLE_RCLONE="${ENABLE_RCLONE,,}"  # lowercase input
  ENABLE_RCLONE="${ENABLE_RCLONE:-$DEFAULT_ENABLE_RCLONE}"
  if [[ "$ENABLE_RCLONE" =~ ^(yes|no)$ ]]; then
    break
  else
    echo "❌ Please type 'yes' or 'no'."
  fi
done

# === Tailscale ===
while true; do
  read -p "🔒 Enable remote access with Tailscale? (yes/no) [Default: $DEFAULT_ENABLE_TAILSCALE]: " ENABLE_TAILSCALE
  ENABLE_TAILSCALE="${ENABLE_TAILSCALE,,}"  # lowercase input
  ENABLE_TAILSCALE="${ENABLE_TAILSCALE:-$DEFAULT_ENABLE_TAILSCALE}"
  if [[ "$ENABLE_TAILSCALE" =~ ^(yes|no)$ ]]; then
    break
  else
    echo "❌ Please type 'yes' or 'no'."
  fi
done

# === Configuration Summary ===
echo ""
echo "📋 Configuration Summary:"
echo "-----------------------------"
echo "📛 Server Name:         $SERVER_NAME"
echo "🌐 Server Port:         $SERVER_PORT"
echo "🎮 Minecraft Version:   $MINECRAFT_VERSION"
echo "⚙️  Server Type:         $SERVER_TYPE"
echo "🔌 Enable Geyser:       $ENABLE_GEYSER"
echo "🧠 Memory Allocation:   ${MEMORY_ALLOCATION}GB"
echo "☁️  Rclone Backups:      $ENABLE_RCLONE"
echo "🔒 Tailscale Enabled:   $ENABLE_TAILSCALE"
echo "📂 Install Directory:   $HOME/minecraft_servers/$SERVER_NAME"
echo "-----------------------------"

# Ask for confirmation
while true; do
  read -p "✅ Proceed with this configuration? (yes/no): " CONFIRM
  case "$CONFIRM" in
    [yY]|[yY][eE][sS])
      echo "🚀 Starting setup..."
      break
      ;;
    [nN]|[nN][oO])
      echo "❌ Setup cancelled by user."
      exit 1
      ;;
    *)
      echo "❌ Please enter 'yes' or 'no'."
      ;;
  esac
done

# === 2. Directory Setup ===
# Create folders:
# - Main server directory
# - `mods/`, `config/`, `scripts/`, `backups/`

# === 3. Generate .env File ===
# Create a .env file with captured/default values

# === 4. Generate docker-compose.yml ===
# Write compose config with:
# - Vanilla or modded image
# - Bind volumes
# - Ports
# - Geyser/Floodgate if enabled

# === 5. Optional: Configure Geyser/Floodgate ===
# Write configs if enabled

# === 6. Optional: Generate rclone/backup scripts ===
# Add backup script to `scripts/` if enabled

# === 7. Optional: Set Up Tailscale ===
# Inject tailscale sidecar container if selected

# === 8. Permissions & Final Review ===
# `chmod +x` relevant scripts and display summary

# === 9. Launch Container ===
# Run `docker compose up -d`

# === 10. Completion Message ===
# Final messages, including tips and where to go next
