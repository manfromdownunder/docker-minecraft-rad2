#!/bin/bash

# Define the path to the flag file
FLAG_FILE="/minecraft-server/first_run_completed.flag"

# Validate environment variables, if needed
# (your validation code here, if any)

# Check for the flag file
if [ ! -f "$FLAG_FILE" ]; then
  # Flag file doesn't exist, this must be the first run
  # Create the flag file
  touch "$FLAG_FILE"
  echo "First run detected, flag file created. Exiting."
  exit 0
else
  # Flag file exists, proceed to start the Minecraft server
  echo "Flag file detected, starting Minecraft server."
  java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui
fi
