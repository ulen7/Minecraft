#!/bin/bash

# A script to generate a docker-compose.yml for a Minecraft server.

# === 0. Constants & Defaults ===
DEFAULT_SERVER_NAME="mc_server"
DEFAULT_VERSION="1.21"
DEFAULT_SERVER_TYPE="fabric"
DEFAULT_MEMORY="4G"
DEFAULT_JPORT="25565"
DEFAULT_BPORT="19132"
DEFAULT_IMAGE="itzg/minecraft-server"
DEFAULT_SEED=""
DEFAULT_USE_GEYSER="no"
DEFAULT_ENABLE_BACKUPS="no"
DEFAULT_ENABLE_TAILSCALE="no"

# === 1. Helper Functions ===
# Reusable function for handling yes/no prompts
prompt_yes_no() {
    local prompt_text="$1"
    local default_value="$2"
    local input

    while true; do
        read -p "$prompt_text" input
        input="${input:-$default_value}" # Apply default if input is empty
        input="${input,,}" # Convert to lowercase

        case "$input" in
            y|yes) echo "yes"; return 0 ;;
            n|no)  echo "no";  return 0 ;;
            *)     echo "❌ Please enter 'yes' or 'no'." ;;
        esac
    done
}

# === 2. Intro & User Prompts ===
echo "📝 Let's configure your Minecraft server..."
echo "Pressing Enter will select the default option shown in [brackets]."

# === Server Name ===
while true; do
    read -p "📛 Enter a name for your server [${DEFAULT_SERVER_NAME}]: " SERVER_NAME
    SERVER_NAME="${SERVER_NAME:-$DEFAULT_SERVER_NAME}"
    if [[ "$SERVER_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        break
    else
        echo "❌ Invalid server name. Use only letters, numbers, underscores, or dashes."
    fi
done

# === Minecraft Version ===
while true; do
    read -p "🧱 Enter the Minecraft version [${DEFAULT_VERSION}]: " MC_VERSION
    MC_VERSION="${MC_VERSION:-$DEFAULT_VERSION}"
    if [[ "$MC_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        break
    else
        echo "❌ Invalid version format. Use format like '1.20.4' or '1.21'."
    fi
done

# === Server Type ===
echo "🛠️ Select the server type:"
PS3="➡️ Choose an option [default: ${DEFAULT_SERVER_TYPE}]: "
options=("vanilla" "fabric" "spigot" "paper")
select opt in "${options[@]}"; do
    if [[ -z "$REPLY" ]]; then # Check if user just pressed Enter
        SERVER_TYPE="$DEFAULT_SERVER_TYPE"
        echo "ℹ️ Defaulting to: $SERVER_TYPE"
        break
    elif [[ " ${options[*]} " == *" $opt "* ]]; then
        SERVER_TYPE="$opt"
        break
    else
        echo "❌ Invalid option. Please choose a number from the list."
    fi
done

# === Memory Allocation ===
while true; do
    read -p "🧠 How much memory to allocate (e.g., 4G, 8G) [${DEFAULT_MEMORY}]: " MEMORY
    MEMORY="${MEMORY:-$DEFAULT_MEMORY}"
    if [[ "$MEMORY" =~ ^[0-9]+G$ ]]; then
        break
    else
        echo "❌ Please enter a number followed by 'G' (e.g., 4G)."
    fi
done

# === Java Port ===
while true; do
    read -p "🌐 Enter the Java Edition port [${DEFAULT_JPORT}]: " MC_JPORT
    MC_JPORT="${MC_JPORT:-$DEFAULT_JPORT}"
    if [[ "$MC_JPORT" =~ ^[0-9]+$ ]] && [ "$MC_JPORT" -ge 1024 ] && [ "$MC_JPORT" -le 65535 ]; then
        break
    else
        echo "❌ Invalid port. Please enter a number between 1024 and 65535."
    fi
done

# === Bedrock Port ===
while true; do
    read -p "🌐 Enter the Bedorck Edition port [${DEFAULT_BPORT}]: " MC_BPORT
    MC_BPORT="${MC_BPORT:-$DEFAULT_BPORT}"
    if [[ "$MC_BPORT" =~ ^[0-9]+$ ]] && [ "$MC_BPORT" -ge 1024 ] && [ "$MC_BPORT" -le 65535 ]; then
        break
    else
        echo "❌ Invalid port. Please enter a number between 1024 and 65535."
    fi
done

# === SEED ===
while true; do
    read -p "🌐 Enter desired seed [${DEFAULT_SEED}]: " MC_SEED
    MC_SEED="${MC_SEED:-$DEFAULT_SEED}"
    if [[ "$MC_SEED" =~ ^[0-9]+$ ]] && [ "$MC_SEED" -ge 0 ] && [ "$MC_SEED" -le 9999999999999999999 ]; then
        break        
    else
        echo "❌ Invalid Seed. Please enter a number between 0 and 9999999999999999999."
    fi
done


# === Optional Features (using the helper function) ===
USE_GEYSER=$(prompt_yes_no "🌉 Enable Geyser for Bedrock cross-play? (y/n) [${DEFAULT_USE_GEYSER}]: " "$DEFAULT_USE_GEYSER")
ENABLE_BACKUPS=$(prompt_yes_no "☁️ Enable automatic backups? (y/n) [${DEFAULT_ENABLE_BACKUPS}]: " "$DEFAULT_ENABLE_BACKUPS")
ENABLE_TAILSCALE=$(prompt_yes_no "🔒 Enable remote access with Tailscale? (y/n) [${DEFAULT_ENABLE_TAILSCALE}]: " "$DEFAULT_ENABLE_TAILSCALE")

# === 3. Configuration Summary ===
SERVER_DIR="$HOME/minecraft_servers/$SERVER_NAME"
echo ""
echo "📋 Configuration Summary:"
printf "%-22s %s\n" "----------------------" "----------------------------------------"
printf "📛 %-20s: %s\n" "Server Name" "$SERVER_NAME"
printf "🧱 %-20s: %s\n" "Minecraft Version" "$MC_VERSION"
printf "⚙️ %-20s: %s\n" "Server Type" "$SERVER_TYPE"
printf "🧠 %-20s: %s\n" "Memory" "$MEMORY"
printf "🌐 %-20s: %s\n" "Java Port" "$MC_JPORT"
printf "🌉 %-20s: %s\n" "Enable Geyser" "$USE_GEYSER"
printf "🌉 %-20s: %s\n" "SEED" "https://www.chunkbase.com/apps/seed-map#seed=""$MC_SEED"
if [ "$USE_GEYSER" == "yes" ]; then
    printf "📱 %-20s: %s\n" "Bedrock Port" "$MC_BPORT"
fi
printf "☁️ %-20s: %s\n" "Enable Backups" "$ENABLE_BACKUPS"
printf "🔒 %-20s: %s\n" "Enable Tailscale" "$ENABLE_TAILSCALE"
printf "📂 %-20s: %s\n" "Install Directory" "$SERVER_DIR"
printf "%-22s %s\n" "----------------------" "----------------------------------------"

# === 4. Confirmation & Action ===
CONFIRMATION=$(prompt_yes_no "✅ Proceed with this configuration? (y/n) [y]: " "y")
if [ "$CONFIRMATION" == "no" ]; then
    echo "❌ Setup cancelled by user."
    exit 1
fi

echo "🚀 Generating docker-compose.yml..."
mkdir -p "$SERVER_DIR"

# Create the docker-compose.yml file
cat > "$SERVER_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  mc:
    image: ${DEFAULT_IMAGE}
    container_name: ${SERVER_NAME}
    restart: unless-stopped
    ports:
      - "${MC_JPORT}:25565"
$( [ "$USE_GEYSER" == "yes" ] && echo "      - \"${DEFAULT_BPORT}:${DEFAULT_BPORT}/udp\"" )
    environment:
      EULA: "TRUE"
      VERSION: "${MC_VERSION}"
      TYPE: "${SERVER_TYPE}"
      MEMORY: "${MEMORY}"
$( [ "$USE_GEYSER" == "yes" ] && echo "      GEYSER: \"TRUE\"" )
$( [ "$ENABLE_BACKUPS" == "yes" ] && echo "      BACKUP_INTERVAL: \"24h\"" )
$( [ "$ENABLE_TAILSCALE" == "yes" ] && echo "      ENABLE_TAILSCALE: \"true\"" )
    volumes:
      - ./data:/data

EOF

echo "✅ Success! Your 'docker-compose.yml' has been created in:"
echo "   $SERVER_DIR"
echo ""
echo "To start your server, run these commands:"
echo "   cd $SERVER_DIR"
echo "   docker-compose up -d"
