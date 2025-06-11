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
echo "You can left blank by just pressing enter"
# - Server name
read -p "📛 Please enter a name for your server. If left blank, '${DEFAULT_SERVER_NAME}' will be used: " SERVER_NAME
SERVER_NAME="${SERVER_NAME:-$DEFAULT_SERVER_NAME}"

# - Minecraft version
read -p "🎮 Enter the Minecraft version to use (e.g., 1.20.4). Default is '${DEFAULT_MC_VERSION}': " MC_VERSION
MC_VERSION="${MC_VERSION:-$DEFAULT_MC_VERSION}"

# - Server type (Fabric, Paper, etc.)
# - Memory allocation
# - Ports
read -p "🌐 Enter the port number for the Java server. Default is '${DEFAULT_JPORT}': " MC_JPORT
MC_JPORT="${MC_JPORT:-$DEFAULT_JPORT}"

# - Whether to use Geyser/Floodgate


# - Enable rclone backups
# - Enable Tailscale
# (Use default values if inputs are blank)

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
