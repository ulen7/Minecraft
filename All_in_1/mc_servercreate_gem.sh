#!/bin/bash

# A script to generate a docker-compose.yml for a Minecraft server.

# === 0. Constants & Defaults ===
DEFAULT_SERVER_NAME="mc_server"
DEFAULT_VERSION="1.21"
DEFAULT_SERVER_TYPE="fabric"
DEFAULT_MEMORY="4"
DEFAULT_JPORT="25565"
DEFAULT_BPORT="19132"
DEFAULT_IMAGE="itzg/minecraft-server"
DEFAULT_SEED=""
DEFAULT_USE_GEYSER="no"
DEFAULT_ENABLE_BACKUPS="no"
DEFAULT_ENABLE_TAILSCALE="no"
# --- NEW: RCON Defaults ---
DEFAULT_ENABLE_RCON_WEB="no"
DEFAULT_RCON_PORT="25575"
DEFAULT_RCON_WEB_PORT="8080"

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
    # Prompt for a number only, indicating the valid range.
    read -p "🧠 How much memory in GB to allocate (4-32) [${DEFAULT_MEMORY}]: " MEMORY

    # Apply the default value if the user just presses Enter.
    MEMORY="${MEMORY:-$DEFAULT_MEMORY}"

    # First, check if the input is a whole number.
    # Then, check if the number is between 4 and 32 (inclusive).
    if [[ "$MEMORY" =~ ^[0-9]+$ ]] && (( MEMORY >= 4 && MEMORY <= 32 )); then
        # If validation passes, append 'G' to the number and store it.
        MEMORY="${MEMORY}G"
        # Exit the loop.
        break
    else
        # If validation fails, print an error and the loop will repeat.
        echo "❌ Please enter a whole number between 4 and 32."
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

# === NEW SECTION: RCON Configuration ===
ENABLE_RCON_WEB=$(prompt_yes_no "🖥️  Enable RCON Web UI for server console? (y/n) [${DEFAULT_ENABLE_RCON_WEB}]: " "$DEFAULT_ENABLE_RCON_WEB")
if [ "$ENABLE_RCON_WEB" == "yes" ]; then
    while true; do
        read -s -p "🔑 Enter a strong RCON password (will not be displayed): " RCON_PASSWORD
        echo
        if [ -n "$RCON_PASSWORD" ]; then
            break
        else
            echo "❌ Password cannot be empty."
        fi
    done
    while true; do
        read -p "🕸️  Enter the port for the RCON Web UI [${DEFAULT_RCON_WEB_PORT}]: " RCON_WEB_PORT
        RCON_WEB_PORT="${RCON_WEB_PORT:-$DEFAULT_RCON_WEB_PORT}"
        if [[ "$RCON_WEB_PORT" =~ ^[0-9]+$ ]] && [ "$RCON_WEB_PORT" -ge 1024 ] && [ "$RCON_WEB_PORT" -le 65535 ]; then
            break
        else
            echo "❌ Invalid port. Please enter a number between 1024 and 65535."
        fi
    done
fi


# === Optional Features (using the helper function) ===
USE_GEYSER=$(prompt_yes_no "🌉 Enable Geyser for Bedrock cross-play? (y/n) [${DEFAULT_USE_GEYSER}]: " "$DEFAULT_USE_GEYSER")
ENABLE_BACKUPS=$(prompt_yes_no "☁️ Enable automatic backups? (y/n) [${DEFAULT_ENABLE_BACKUPS}]: " "$DEFAULT_ENABLE_BACKUPS")

# === NEW: Tailscale Prompt & Secure Key Input ===
ENABLE_TAILSCALE=$(prompt_yes_no "🔒 Enable remote access with Tailscale? (y/n) [${DEFAULT_ENABLE_TAILSCALE}]: " "$DEFAULT_ENABLE_TAILSCALE")
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
    echo "Please generate an Auth Key from your Tailscale Admin Console.For more information go here"
    echo "https://tailscale.com/kb/1085/auth-keys"
    echo "It is recommended to use an Ephemeral, Pre-authorized, and Tagged key."
    while true; do
        read -s -p "🔑 Enter your Tailscale Auth Key (will not be displayed): " TS_AUTHKEY
        echo
        if [ -n "$TS_AUTHKEY" ]; then
            break
        else
            echo "❌ Auth Key cannot be empty."
        fi
    done
fi

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
# --- ADDED: RCON Summary ---
printf "🖥️  %-20s: %s\n" "Enable RCON Web UI" "$ENABLE_RCON_WEB"
if [ "$ENABLE_RCON_WEB" == "yes" ]; then
    printf "🕸️  %-20s: %s\n" "RCON Web UI Port" "$RCON_WEB_PORT"
fi
printf "📂 %-20s: %s\n" "Install Directory" "$SERVER_DIR"
printf "%-22s %s\n" "----------------------" "----------------------------------------"

# === 4. Confirmation & Action ===
CONFIRMATION=$(prompt_yes_no "✅ Proceed with this configuration? (y/n) [y]: " "y")
if [ "$CONFIRMATION" == "no" ]; then
    echo "❌ Setup cancelled by user."
    exit 1
fi

# === 4. Directory Setup ===
# Create folders:
echo "Generating server folder..."
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR" || exit 1

# === 5. Generate docker-compose.yml ===

# --- NEW: Prepare environment blocks dynamically ---
# This makes the main 'cat' command below much cleaner.

# Initialize an empty variable for mod environment settings.
MOD_ENV_BLOCK=""

# Check if the server type is Fabric to add mods.
if [ "$SERVER_TYPE" == "fabric" ]; then
    # Start with the essential Fabric API mod.
    MODS_LIST="fabric-api"

    # If Geyser is also enabled, add the Geyser-Fabric integration mod.
    if [ "$USE_GEYSER" == "yes" ]; then
        MODS_LIST="${MODS_LIST},geyser-fabric"
    fi
    
    # Create the final YAML block for the Modrinth projects.
    MOD_ENV_BLOCK="      MODRINTH_PROJECTS: \"${MODS_LIST}\""
fi


# --- Create the docker-compose.yml file ---

cat > docker-compose.yml <<EOF
version: '3.8'
services:
  minecraft:
    image: ${DEFAULT_IMAGE}
    container_name: ${SERVER_NAME}
    restart: unless-stopped
    tty: true
    stdin_open: true
EOF

if [ "$ENABLE_TAILSCALE" == "yes" ]; then
  echo "    network_mode: \"service:tailscale-sidecar\"" >> docker-compose.yml
fi

cat >> docker-compose.yml <<EOF
    ports:
      - \"${MC_JPORT}:${MC_JPORT}\""
EOF
if [ "$USE_GEYSER" == "yes" ]; then
  echo "      - \"${MC_BPORT}:${MC_BPORT}/udp\"" >> docker-compose.yml
fi
cat >> docker-compose.yml <<EOF
    environment:
      EULA: "TRUE"
      VERSION: "${MC_VERSION}"
      TYPE: "${SERVER_TYPE^^}"
      MEMORY: "${MEMORY}"
      SEED: "${MC_SEED}"
EOF

[ -n "$MOD_ENV_BLOCK" ] && echo "$MOD_ENV_BLOCK" >> docker-compose.yml

cat >> docker-compose.yml <<EOF
    volumes:
      - ${SERVER_DIR}:/data
EOF

# Append Tailscale service if needed
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
cat >> docker-compose.yml <<EOF

  tailscale-sidecar:
    image: tailscale/tailscale:latest
    hostname: ${SERVER_NAME}
    container_name: ${SERVER_NAME}-tailscale-sidecar
    environment:
      - TS_AUTHKEY=${TS_AUTHKEY}
      - TS_EXTRA_ARGS=--advertise-tags=tag:minecraft-server
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
    volumes:
      - ./tailscale-state:/var/lib/tailscale
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - net_admin
    restart: unless-stopped
EOF
fi

echo "✅ Success! Your 'docker-compose.yml' has been created in:"
echo "   $SERVER_DIR"
echo ""
echo "To start your server, run these commands:"
echo "   cd $SERVER_DIR"
echo "   docker-compose up -d"

#Tailscale prompt
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
echo ""
echo "🔒 Tailscale is enabled. Your server will be available on your Tailnet."
echo "   Check your Tailscale admin console for the new machine named '${SERVER_NAME}'."
echo "   You can connect in Minecraft using its Tailscale IP or hostname."
else
echo ""
echo "🌐 Your server should be available at: localhost:${MC_JPORT}"
fi
fi


# === 5. Optional: Configure Geyser/Floodgate ===
# Write configs if enabled

# bedrock: 
    # The IP address that will listen for connections. 
    # Generally, you should only uncomment and change this if you want to limit what IPs can connect to your server. 
    #address: 0.0.0.0 

    # The port that will listen for connections. This is the port that Bedrock players will use to connect to your server.
    # port: 19132 

    # Some hosting services change your Java port everytime you start the server and require the same port to be used for Bedrock. 
    # This option makes the Bedrock port the same as the Java port every time you start the server. 
    # This option is for the plugin version only. 
    # clone-remote-port: false 

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
