#!/bin/bash
set -euo pipefail

# What this does:
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.
# -o pipefail: The return value of a pipeline is the status of the last command
#              to exit with a non-zero status, or zero if no command fails.

# Minecraft Server Setup Script
# Maintained at: https://github.com/ulen7/Minecraft/edit/main/All_in_1/
# Version: 1.0.0

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
            *)     echo "Please enter 'yes' or 'no'." ;;
        esac
    done
}


# === 2. Intro & User Prompts ===
echo "Let's configure your Minecraft server..."
echo "Pressing Enter will select the default option shown in [brackets]."

# === Server Name ===
RESERVED_NAMES=("con" "nul" "prn" "aux" "clock\$" "com1" "com2" "com3" "lpt1" "lpt2" "lpt3" "dev" "sys" "proc")

while true; do
    read -p "Enter a name for your server [${DEFAULT_SERVER_NAME}]: " SERVER_NAME
    SERVER_NAME="${SERVER_NAME:-$DEFAULT_SERVER_NAME}"

    # 1. Validate characters
    if ! [[ "$SERVER_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid name. Use only letters, numbers, underscores, or dashes."
        continue
    fi

    # 2. Check against reserved/system names
    for reserved in "${RESERVED_NAMES[@]}"; do
        if [[ "${SERVER_NAME,,}" == "$reserved" ]]; then
            echo "'$SERVER_NAME' is a reserved system name. Please choose another."
            continue 2
        fi
    done

    # 3. Check for existing server folders, case-insensitively
    SERVER_ROOT="$HOME/minecraft_servers"
    if [ ! -d "$SERVER_ROOT" ]; then
        mkdir -p "$SERVER_ROOT"
    fi

    existing_dirs=$(find "$SERVER_ROOT" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | tr '[:upper:]' '[:lower:]')

    if echo "$existing_dirs" | grep -qx "${SERVER_NAME,,}"; then
        echo "A server with a similar name already exists: '$SERVER_NAME'"
        while true; do
            read -p "Type [r] to rename or [c] to cancel: " choice
            case "${choice,,}" in
                r) break ;;
                c) echo "Setup cancelled."; exit 1 ;;
                *) echo "Invalid choice. Please type 'r' to rename or 'c' to cancel." ;;
            esac
        done
    else
        break
    fi
done

# Directory Creation

SERVER_DIR="$SERVER_ROOT/$SERVER_NAME"
SCRIPT_LOG="$SERVER_DIR/minecraft_name_setup.log"

echo "Generating server folder..."

mkdir -p "$SERVER_DIR" || {
    echo "Failed to create server directory: $SERVER_DIR"
    exit 1
}

touch "$SCRIPT_LOG" || {
    echo "Cannot write to log file: $SCRIPT_LOG"
    exit 1
}

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $*" >> "$SCRIPT_LOG"
}

log "=== Minecraft Setup Started ==="
log "Minecraft server $SERVER_NAME created"

# === Minecraft Version ===
while true; do
    read -p "Enter the Minecraft version [${DEFAULT_VERSION}]: " MC_VERSION
    MC_VERSION="${MC_VERSION:-$DEFAULT_VERSION}"
    if [[ "$MC_VERSION" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        log "Minecraft version set to version: $MC_VERSION"
        break
    else
        log "Invalid Minecraft version input: $MC_VERSION"
        echo "Invalid version format. Use format like '1.20.4' or '1.21'."
    fi
done

# === Server Type ===
echo "Select the server type:"
PS3="Choose an option [default: ${DEFAULT_SERVER_TYPE}]: "
options=("vanilla" "fabric" "spigot" "paper")
select opt in "${options[@]}"; do
    if [[ -z "$REPLY" ]]; then # Check if user just pressed Enter
        SERVER_TYPE="$DEFAULT_SERVER_TYPE"
        echo "Defaulting to: $SERVER_TYPE"
        log "Minecraft type set to: $SERVER_TYPE"
        break
    elif [[ " ${options[*]} " == *" $opt "* ]]; then
        SERVER_TYPE="$opt"
        log "Minecraft type set to: $SERVER_TYPE"
        break
    else
        echo "Invalid option. Please choose a number from the list."
        log "Failed to select a server type"
    fi
done

# === Memory Allocation ===
while true; do
    # Prompt for a number only, indicating the valid range.
    read -p "How much memory in GB to allocate (4-32) [${DEFAULT_MEMORY}]: " MEMORY

    # Apply the default value if the user just presses Enter.
    MEMORY="${MEMORY:-$DEFAULT_MEMORY}"

    # First, check if the input is a whole number.
    # Then, check if the number is between 4 and 32 (inclusive).
    if [[ "$MEMORY" =~ ^[0-9]+$ ]] && (( MEMORY >= 4 && MEMORY <= 32 )); then
        # If validation passes, append 'G' to the number and store it.
        MEMORY="${MEMORY}G"
        log "$MEMORY selected for memory"
        # Exit the loop.
        break
    else
        # If validation fails, print an error and the loop will repeat.
        echo "Please enter a whole number between 4 and 32."
        log "$MEMORY is an invalid value to select for memory"
    fi
done

# === Java Port ===
while true; do
    read -p "Enter the Java Edition port (if blank default port: [${DEFAULT_JPORT}] will be used): " MC_JPORT
    MC_JPORT="${MC_JPORT:-$DEFAULT_JPORT}"

    if [[ "$MC_JPORT" =~ ^[0-9]+$ ]] && [ "$MC_JPORT" -ge 1024 ] && [ "$MC_JPORT" -le 65535 ]]; then
        # Check if port is in use
        if ss -tuln | awk '{print $5}' | grep -Eq ":${MC_JPORT}\$"; then
            echo "Port $MC_JPORT is already in use by another service."
            log "Port $MC_JPORT already in use."
        else
            log "$MC_JPORT port selected for Java Minecraft"
            break
        fi
    else
        echo "Invalid port. Please enter a number between 1024 and 65535."
        log "$MC_JPORT is an invalid port"
    fi
done

# === Optional Features - Geyser for Bedrock compatibility===
USE_GEYSER=$(prompt_yes_no "Enable Geyser for Bedrock cross-play? (y/n) [${DEFAULT_USE_GEYSER}]: " "$DEFAULT_USE_GEYSER")

# === Bedrock Port ===
if [ "$USE_GEYSER" == "yes" ]; then
    log "Geyser enabled. Asking for Bedrock port..."

    while true; do
        read -p "Enter the Bedrock Edition port, if blank default port [${DEFAULT_BPORT}]: " MC_BPORT
        MC_BPORT="${MC_BPORT:-$DEFAULT_BPORT}"

        # First, validate the port format and range
        if [[ "$MC_BPORT" =~ ^[0-9]+$ ]] && [ "$MC_BPORT" -ge 1024 ] && [ "$MC_BPORT" -le 65535 ]; then
            # If valid, then check for conflicts
            if [ "$MC_BPORT" == "$MC_JPORT" ] || ss -tuln | awk '{print $5}' | grep -Eq ":${MC_BPORT}\$"; then
                echo "Bedrock port $MC_BPORT is either already in use or conflicts with Java port $MC_JPORT."
                log "Bedrock port conflict: $MC_BPORT matches Java port or is in use."
            else
                # Success! Port is valid and not in use.
                log "Bedrock port selected: $MC_BPORT"
                break
            fi
        else
            # Failure! Port format/range is invalid.
            echo "Invalid port. Please enter a number between 1024 and 65535."
            log "Invalid Bedrock port entered: $MC_BPORT"
        fi
    done
else
    log "Geyser not enabled. Skipping Bedrock port configuration."
fi

# === SEED ===
while true; do
    read -p "Enter desired seed [${DEFAULT_SEED}]: " MC_SEED
    MC_SEED="${MC_SEED:-$DEFAULT_SEED}"
    if [[ "$MC_SEED" =~ ^[0-9]+$ ]] && [ "$MC_SEED" -ge 0 ] && [ "$MC_SEED" -le 9999999999999999999 ]; then
        log "Seed chosen: $MC_SEED"
        break        
    else
        log "Invalid Seed chosen: $MC_SEED"
        echo "Invalid Seed. Please enter a number between 0 and 9999999999999999999."
    fi
done

# === Optional Features - Back-Ups===
ENABLE_BACKUPS=$(prompt_yes_no "Enable automatic backups? (y/n) [${DEFAULT_ENABLE_BACKUPS}]: " "$DEFAULT_ENABLE_BACKUPS")

# === NEW: Tailscale Prompt & Secure Key Input ===
ENABLE_TAILSCALE=$(prompt_yes_no "Enable remote access with Tailscale? (y/n) [${DEFAULT_ENABLE_TAILSCALE}]: " "$DEFAULT_ENABLE_TAILSCALE")
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
    log "Tailscale Enabled, setting configuration for tailscale ..."
    echo "Please generate an Auth Key from your Tailscale Admin Console.For more information go here"
    echo "https://tailscale.com/kb/1085/auth-keys"
    echo "It is recommended to use an Ephemeral, Pre-authorized, and Tagged key."
    while true; do
        read -s -p "Enter your Tailscale Auth Key (will not be displayed): " TS_AUTHKEY
        echo
        if [ -z "$TS_AUTHKEY" ]; then
            echo "Auth Key cannot be empty."
            continue
        fi
    
        log "Validating Tailscale Auth Key..."
        echo "Validating key with Tailscale... this may take a moment."
        
        # Capture all output (stdout and stderr) into a variable
        VALIDATION_OUTPUT=$(docker run --rm --privileged \
            --cap-add=NET_ADMIN \
            --device /dev/net/tun \
            -e TS_AUTHKEY="$TS_AUTHKEY" \
            -e TS_STATE_DIR="/tmp/state" \
            tailscale/tailscale tailscale up --authkey="$TS_AUTHKEY" --ephemeral 2>&1)
        
        # Check the output for the success message
        if echo "$VALIDATION_OUTPUT" | grep -q "Logged in as"; then
            log "Auth Key is valid."
            echo "Auth Key is valid."
        
            # --- SUCCESS CASE ---
            # Create .env file for security
            echo "TS_AUTHKEY=${TS_AUTHKEY}" > "${SERVER_DIR}/.env"
            log "Created .env file to securely store your Tailscale key."
            echo "Created .env file for secure key storage."
        
            # Create .gitignore file
            cat > "${SERVER_DIR}/.gitignore" <<EOF
        # Ignore sensitive environment variables
        .env
        
        # Ignore log files and state directories
        *.log
        tailscale-state/
        EOF
            log "Created .gitignore file."
            break
        else
            # --- FAILURE CASE ---
            log "Invalid Auth Key or Docker error occurred."
            echo "Validation failed. Please check the key and try again."
        
            # Provide more specific feedback if possible
            if echo "$VALIDATION_OUTPUT" | grep -q "Cannot connect to the Docker daemon"; then
                log "Docker daemon not running."
                echo "Error: Could not connect to Docker. Is the Docker daemon running?"
            fi
            unset TS_AUTHKEY
        fi
    done
fi



# === 3. Configuration Summary ===
log "Configuration Summary"
echo ""
echo "Configuration Summary:"
printf "%-22s %s\n" "----------------------" "----------------------------------------"
printf "%-20s: %s\n" "Server Name" "$SERVER_NAME"
log "Server Name $SERVER_NAME"
printf "%-20s: %s\n" "Minecraft Version" "$MC_VERSION"
log "Minecraft Version $MC_VERSION"
printf "⚙%-20s: %s\n" "Server Type" "$SERVER_TYPE"
log "Server Type $SERVER_TYPE"
printf "%-20s: %s\n" "Memory" "$MEMORY"
log "Memory allocated $MEMORY"
printf "%-20s: %s\n" "Java Port" "$MC_JPORT"
log "Port for Java MC instances: $MC_JPORT"
printf "%-20s: %s\n" "Enable Geyser" "$USE_GEYSER"
log "Is Geyser enabled? $USE_GEYSER"
printf "%-20s: %s\n" "SEED" "https://www.chunkbase.com/apps/seed-map#seed=""$MC_SEED"
if [ "$USE_GEYSER" == "yes" ]; then
    printf "%-20s: %s\n" "Bedrock Port" "$MC_BPORT"
    log "Port for Bedrock MC instances: $MC_BPORT"
fi
printf "%-20s: %s\n" "Enable Backups" "$ENABLE_BACKUPS"
log "Are Backups enables? $ENABLE_BACKUPS"
printf "%-20s: %s\n" "Enable Tailscale" "$ENABLE_TAILSCALE"
log "Is Tailscale Enabled? $ENABLE_TAILSCALE"

# === 4. Confirmation & Action ===
CONFIRMATION=$(prompt_yes_no "Proceed with this configuration? (y/n) [y]: " "y")
if [ "$CONFIRMATION" == "no" ]; then
    log "Setup cancelled by user"
    echo "Setup cancelled by user."
    exit 1
fi

cd "$SERVER_DIR" || exit 1

# === 5. Generate docker-compose.yml ===

log "Generating docker-compose file in $SERVER_DIR"

# --- NEW: Prepare environment blocks dynamically ---

# Initialize an empty variable for mod environment settings.
MOD_ENV_BLOCK=""

# Check if the server type is Fabric to add mods.
if [ "$SERVER_TYPE" == "fabric" ]; then
    # Start with the essential Fabric API mod.
    MODS_LIST="fabric-api"

    # If Geyser is also enabled, add the Geyser-Fabric integration mod.
    if [ "$USE_GEYSER" == "yes" ]; then
        MODS_LIST="${MODS_LIST},geyser-fabric"
        log "Mods added : $MODS_LIST"
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
# Append Tailscale service if needed
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
# Note: We are still using <<EOF to allow ${SERVER_NAME} to be expanded.
cat >> docker-compose.yml <<EOF

  tailscale-sidecar:
    image: tailscale/tailscale:latest
    hostname: ${SERVER_NAME}
    container_name: ${SERVER_NAME}-tailscale-sidecar
    environment:
      # By using \${TS_AUTHKEY}, the shell writes the literal string "${TS_AUTHKEY}"
      # to the file. Docker Compose will then substitute this with the value
      # from the .env file when the container starts.
      - TS_AUTHKEY=\${TS_AUTHKEY}
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

echo "Success! Your 'docker-compose.yml' has been created in: $SERVER_DIR"
log "Success! Your 'docker-compose.yml' has been created in: $SERVER_DIR"

echo "   $SERVER_DIR"
echo ""
echo "To manually start your server, run these commands:"
echo "   cd $SERVER_DIR"
echo "   docker-compose up -d"

# === 6. Launch & Final Configuration ===

# Ask the user if they want to start the server now
LAUNCH_NOW=$(prompt_yes_no "Your files are generated. Would you like to start the server now? (y/n) [y]: " "y")

if [ "$LAUNCH_NOW" == "no" ]; then
    echo "All set. You can start your server later by running the commands listed above."
    log "Docker container will be launched manually"
    exit 0
fi

# --- Start the Docker Container ---
echo "Starting the server in the background..."
if ! (cd "$SERVER_DIR" && docker compose up -d); then
    echo "Docker Compose failed to start. Please check for errors with docker logs ${SERVER_NAME}."
    exit 1
fi

#Tailscale prompt
if [ "$ENABLE_TAILSCALE" == "yes" ]; then
echo ""
echo "    Tailscale is enabled. Your server will be available on your Tailnet."
echo "    Check your Tailscale admin console at https://login.tailscale.com/admin/machines for the new machine named '${SERVER_NAME}'."
echo "    You can connect in Minecraft using its Tailscale IP or hostname."
else
echo ""
echo "    Your server should be available at: hostname:${MC_JPORT} for Java instances"
if [ "$USE_GEYSER" == "yes" ]; then
  echo "    Your server should be available at: hostname:${MC_BPORT} for Bedrock instances"
fi
fi

# Wait time to initialize Server
echo "Waiting for the server to initialize... (This may take a few minutes)"
TIMEOUT=300 # 5 minutes
SECONDS=0
while ! docker logs "$SERVER_NAME" 2>&1 | grep -q "Server marked as running"; do
    if [ $SECONDS -gt $TIMEOUT ]; then
        echo "🚨 Server did not start within the timeout period."
        log "Error starting server, check the logs for the docker container with: docker logs ${SERVER_NAME}"
        echo "Check the logs with: docker logs ${SERVER_NAME}"
        exit 1
    fi
    printf "."
    sleep 5
done
echo ""
echo "Server has initialized successfully."
log "Server has initialized successfully."


# --- Configure Geyser ---
if [ "$USE_GEYSER" == "yes" ]; then
    echo "Attempting to configure Geyser..."
    log "Attempting to configure Geyser..."
    PLUGINS_DIR="$SERVER_DIR/config"
    GEYSER_CONFIG_PATH=$(find "$PLUGINS_DIR" -type f -name "config.yml" -path "*/Geyser-*/config.yml" | head -n 1)

    if [ -f "$GEYSER_CONFIG_PATH" ]; then
        echo "Found Geyser config at: $GEYSER_CONFIG_PATH"
        log "Found Geyser config at: $GEYSER_CONFIG_PATH"
        
        # WARNING: The following sed command is fragile and depends on the exact
        # format of Geyser's config.yml. If Geyser updates, this may break.

        CONFIRM_SED=$(prompt_yes_no "Apply this change to the config file? (y/n) [y]: " "y")
        if [ "$CONFIRM_SED" == "yes" ]; then
            sed -i -E "/^[[:space:]]*bedrock:[[:space:]]*$/,/^[[:alpha:]]/ {
                /^[[:space:]]*port:[[:space:]]*[0-9]+[[:space:]]*$/ s/[0-9]+/${MC_BPORT}/
            }" "$GEYSER_CONFIG_PATH"
            log "Updated Bedrock port to ${MC_BPORT}."
            echo "Updated Bedrock port to ${MC_BPORT}."

            echo "Restarting the Minecraft container to apply new settings..."
            (cd "$SERVER_DIR" && docker compose restart "$SERVER_NAME")
            echo "Geyser configuration complete!"
        else
            echo "Change skipped. You may need to update the port manually later."
            log "Change skipped. Port my need to be changed manually later."
        fi
    else
        echo "    Could not find Geyser 'config.yml'. The server may need more time to start, or Geyser may not be installed correctly."
        echo "    You may need to set the Bedrock port to ${MC_BPORT} manually and restart the container."
        log "Could not find Geyser, port to be set manually later"
    fi
fi

# === 7. Optional: Generate rclone/backup scripts ===

# === NEW: Backup Configuration ===
if [ "$ENABLE_BACKUPS" == "yes" ]; then
    echo "--- Configuring Backups ---"
    log "Attempting to setup the backups configuration ..."

    # Step 1: Check if rclone is installed
    if ! command -v rclone &> /dev/null; then
        echo "rclone is not installed, but is required for Google Drive backups."
        log "rclone is not installed, but is required for Google Drive backups."
        INSTALL_RCLONE=$(prompt_yes_no "    Would you like to try and install it now? (requires sudo) (y/n) [y]: " "y")
        if [ "$INSTALL_RCLONE" == "yes" ]; then
            # Check for sudo permissions before attempting install
            log "Attempting to install rclone"
            if ! sudo -v; then
                echo "Sudo permissions are required to install packages. Please run the script with sudo or install rclone manually."
                exit 1
            fi
            echo "Installing rclone for Debian/Ubuntu..."
            sudo apt-get update && sudo apt-get install -y rclone
            if ! command -v rclone &> /dev/null; then
                 echo "rclone installation failed. Please install it manually."
                 log "Failed to install rclone it should be installed manually"
                 exit 1
            fi
            echo "rclone installed successfully."
            log "rclone installed successfully."
        else
            echo "Skipping backup configuration. Please install rclone and re-run to set up backups."
            log "Skipping backup configuration"
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
                    echo "Found rclone remote: ${RCLONE_REMOTE}"
                    break
                else
                    echo "Warning: rclone remote '${RCLONE_REMOTE}' not found. Please ensure it is configured correctly."
                    # Ask user if they want to proceed anyway
                    PROCEED_ANYWAY=$(prompt_yes_no "    Continue anyway? (y/n) [y]: " "y")
                    if [ "$PROCEED_ANYWAY" == "yes" ]; then
                        break
                    fi
                fi
            else
                echo "Remote name cannot be empty."
            fi
        done
    fi
fi

# === Generate Backup Script and Cron Job Info ===

if [ "$ENABLE_BACKUPS" == "yes" ]; then
    log "Generating backup script"
    echo "Generating backup script..."
    
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
WORLD_DATA_DIR="${SERVER_DIR}" # Path to the server's data volume
BACKUP_DIR="${LOCAL_BACKUP_PATH}"
TIMESTAMP=\$(date +'%Y-%m-%d_%H-%M')
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

    log "Backup Script created succesfully"
    # Make the script executable
    chmod +x "$BACKUP_SCRIPT_PATH"
    echo "Backup script created at ${BACKUP_SCRIPT_PATH}"

    # --- Prepare Cron Job Instruction ---
    CRON_JOB="0 3 * * 0 TZ=America/Toronto ${BACKUP_SCRIPT_PATH} >> ${SCRIPTS_DIR}/cron.log 2>&1"
    
    # Store the cron instruction in a variable to display at the end
    BACKUP_INSTRUCTION=$(cat <<EOF

---
 backups:
   To automate your backups, add the following line to your system's crontab.
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
log "All taks completed"
echo "All tasks complete. Enjoy your server!"
