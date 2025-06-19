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
      - \"${MC_JPORT}:${MC_JPORT}\"
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

# Display Bar snippet
display_progress_bar() {
    local duration=$1
    local message="$2"
    local width=50 # width of the progress bar in characters

    echo "$message"
    for i in $(seq 1 "$duration"); do
        percent=$((i * 100 / duration))
        filled=$((i * width / duration))

        # Build the filled and empty sections of the bar
        bar_filled=$(printf "%${filled}s" | tr ' ' '#')
        bar_empty=$(printf "%$((width - filled))s" | tr ' ' '-')

        printf "\r[%s%s] %d%%" "$bar_filled" "$bar_empty" "$percent"
        sleep 1
    done
    echo ""
}


# === 6. Launch & Final Configuration ===

# Ask the user if they want to start the server now
LAUNCH_NOW=$(prompt_yes_no "✅ Your files are generated. Would you like to start the server now? (y/n) [y]: " "y")

if [ "$LAUNCH_NOW" == "no" ]; then
    echo "👍 All set. You can start your server later by running the commands listed above."
    exit 0
fi

# --- Start the Docker Container ---
echo "🚀 Starting the server in the background..."
if ! (cd "$SERVER_DIR" && docker compose up -d); then
    echo "❌ Docker Compose failed to start. Please check for errors."
    exit 1
fi

# --- Wait for Server Initialization ---
display_progress_bar 180 "⏳ Giving the server 3 minutes to initialize and generate files..."

# --- Configure Geyser ---
if [ "$USE_GEYSER" == "yes" ]; then
    echo "⚙️  Attempting to configure Geyser..."

    PLUGINS_DIR="$SERVER_DIR/config"
    GEYSER_CONFIG_PATH=$(find "$PLUGINS_DIR" -type f -name "config.yml" -path "*/Geyser-*/config.yml" | head -n 1)

    if [ -f "$GEYSER_CONFIG_PATH" ]; then
        echo "✅ Found Geyser config at: $GEYSER_CONFIG_PATH"
        
        echo "🔍 Previewing Bedrock port change:"
        sed -nE "/^[[:space:]]*bedrock:[[:space:]]*$/,/^[[:alpha:]]/ {
            /^[[:space:]]*port:[[:space:]]*[0-9]+[[:space:]]*$/ s/[0-9]+/${MC_BPORT}/p
        }" "$GEYSER_CONFIG_PATH"

        CONFIRM_SED=$(prompt_yes_no "Apply this change to the config file? (y/n) [y]: " "y")
        if [ "$CONFIRM_SED" == "yes" ]; then
            sed -i -E "/^[[:space:]]*bedrock:[[:space:]]*$/,/^[[:alpha:]]/ {
                /^[[:space:]]*port:[[:space:]]*[0-9]+[[:space:]]*$/ s/[0-9]+/${MC_BPORT}/
            }" "$GEYSER_CONFIG_PATH"
            echo "✅ Updated Bedrock port to ${MC_BPORT}."

            echo "🔄 Restarting the Minecraft container to apply new settings..."
            (cd "$SERVER_DIR" && docker compose restart "$SERVER_NAME")
            echo "🎉 Geyser configuration complete!"
        else
            echo "❌ Change skipped. You may need to update the port manually later."
        fi
    else
        echo "⚠️  Could not find Geyser 'config.yml'. The server may need more time to start, or Geyser may not be installed correctly."
        echo "    You may need to set the Bedrock port to ${MC_BPORT} manually and restart the container."
    fi
fi

# === 7. Optional: Generate rclone/backup scripts ===

# === NEW: Backup Configuration ===
if [ "$ENABLE_BACKUPS" == "yes" ]; then
    echo "--- Configuring Backups ---"

    # Step 1: Check if rclone is installed
    if ! command -v rclone &> /dev/null; then
        echo "⚠️  rclone is not installed, but is required for Google Drive backups."
        INSTALL_RCLONE=$(prompt_yes_no "    Would you like to try and install it now? (requires sudo) (y/n) [y]: " "y")
        if [ "$INSTALL_RCLONE" == "yes" ]; then
            # Check for sudo permissions before attempting install
            if ! sudo -v; then
                echo "❌ Sudo permissions are required to install packages. Please run the script with sudo or install rclone manually."
                exit 1
            fi
            echo "Installing rclone for Debian/Ubuntu..."
            sudo apt-get update && sudo apt-get install -y rclone
            if ! command -v rclone &> /dev/null; then
                 echo "❌ rclone installation failed. Please install it manually."
                 exit 1
            fi
            echo "✅ rclone installed successfully."
        else
            echo "Skipping backup configuration. Please install rclone and re-run to set up backups."
            ENABLE_BACKUPS="no" # Disable backups for the rest of the script
        fi
    fi

    # Step 2: Ask for rclone remote name (only if backups are still enabled)
    if [ "$ENABLE_BACKUPS" == "yes" ]; then
         while true; do
            read -p "Enter the name of your configured rclone remote (e.g., gdrive): " RCLONE_REMOTE
            if [ -n "$RCLONE_REMOTE" ]; then
                # Optional: Add a check to see if remote exists
                if rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
                    echo "✅ Found rclone remote: ${RCLONE_REMOTE}"
                    break
                else
                    echo "⚠️  Warning: rclone remote '${RCLONE_REMOTE}' not found. Please ensure it is configured correctly."
                    # Ask user if they want to proceed anyway
                    PROCEED_ANYWAY=$(prompt_yes_no "    Continue anyway? (y/n) [y]: " "y")
                    if [ "$PROCEED_ANYWAY" == "yes" ]; then
                        break
                    fi
                fi
            else
                echo "❌ Remote name cannot be empty."
            fi
        done
    fi
fi

# === Generate Backup Script and Cron Job Info ===

if [ "$ENABLE_BACKUPS" == "yes" ]; then
    echo "⚙️  Generating backup script..."
    
    # Define paths for the backup script
    SCRIPTS_DIR="$SERVER_DIR/scripts"
    BACKUP_SCRIPT_PATH="$SCRIPTS_DIR/backup.sh"
    LOCAL_BACKUP_PATH="$HOME/minecraft_backups/$SERVER_NAME" # A central backup location
    
    mkdir -p "$SCRIPTS_DIR"

    # Dynamically create the backup.sh script using variables from this session
    cat > "$BACKUP_SCRIPT_PATH" << EOF
#!/bin/bash
# Auto-generated backup script for ${SERVER_NAME}

# --- Configuration ---
WORLD_NAME="${SERVER_NAME}"
WORLD_DATA_DIR="${SERVER_DIR}/data" # Path to the server's data volume
BACKUP_DIR="${LOCAL_BACKUP_PATH}"
TIMESTAMP=\$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="\${WORLD_NAME}_\${TIMESTAMP}.tar.gz"
REMOTE_NAME="${RCLONE_REMOTE}"
REMOTE_PATH="minecraft_backups/\${WORLD_NAME}"
LOG_FILE="${SCRIPTS_DIR}/backup.log"

# --- Logging ---
echo "--- Starting Backup for \${WORLD_NAME} at \$(date) ---" >> "\${LOG_FILE}"

# --- Create Backup Directory ---
mkdir -p "\$BACKUP_DIR"

# --- Create Compressed Backup ---
# We back up the 'data' directory mounted from the Docker container
if tar -czf "\$BACKUP_DIR/\$BACKUP_NAME" -C "\$WORLD_DATA_DIR" .; then
    echo "Successfully created local backup: \$BACKUP_NAME" >> "\${LOG_FILE}"
else
    echo "ERROR: Failed to create tarball." >> "\${LOG_FILE}"
    exit 1
fi

# --- Rotate Cloud Backups (Keep 4 most recent) ---
echo "Rotating cloud backups..." >> "${LOG_FILE}"
rclone ls "${REMOTE_NAME}:${REMOTE_PATH}" | awk '{print $2}' | sort -r | tail -n +5 | while read -r file; do
    rclone delete "${REMOTE_NAME}:${REMOTE_PATH}/${file}" >> "${LOG_FILE}" 2>&1
done


# --- Upload to Cloud Storage ---
echo "Uploading to \${REMOTE_NAME}..." >> "\${LOG_FILE}"
if rclone copy "\$BACKUP_DIR/\$BACKUP_NAME" "\${REMOTE_NAME}:\${REMOTE_PATH}"; then
    echo "Successfully uploaded to \${REMOTE_NAME}." >> "\${LOG_FILE}"
else
    echo "ERROR: rclone upload failed." >> "\${LOG_FILE}"
fi

# --- Rotate Cloud Backups (Keep 4 most recent) ---
rclone ls "\${REMOTE_NAME}:\${REMOTE_PATH}" | awk '{print \$2}' | sort -r | tail -n +5 | while read -r file; do
  rclone delete "\${REMOTE_NAME}:\${REMOTE_PATH}/\${file}" >> "\${LOG_FILE}" 2>&1
done

echo "--- Backup Complete ---" >> "\${LOG_FILE}"

EOF

    # Make the script executable
    chmod +x "$BACKUP_SCRIPT_PATH"
    echo "✅ Backup script created at ${BACKUP_SCRIPT_PATH}"

    # --- Prepare Cron Job Instruction ---
    CRON_JOB="0 3 * * 0 TZ=America/Toronto ${BACKUP_SCRIPT_PATH} >> ${SCRIPTS_DIR}/cron.log 2>&1"
    
    # Store the cron instruction in a variable to display at the end
    BACKUP_INSTRUCTION=$(cat <<EOF

---
 backups:
🔒 To automate your backups, add the following line to your system's crontab.
   Run 'crontab -e' and paste this line at the bottom:

   ${CRON_JOB}

   This will run the backup every Sunday at 3:00 AM Toronto time.
EOF
)
fi


# === 8. Completion Message ===

# Display the backup instruction if it was generated
if [ -n "$BACKUP_INSTRUCTION" ]; then
    echo "$BACKUP_INSTRUCTION"
fi

echo "---"
echo "✅ All tasks complete. Enjoy your server!"
