#!/bin/bash

# === 0. Constants & Defaults ===
# Default values and path setups

# === 1. Intro & User Prompts ===
# Greet the user and prompt for:
# - Server name
# - Minecraft version
# - Server type (Fabric, Paper, etc.)
# - Memory allocation
# - Ports
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
