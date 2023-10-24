#!/bin/bash

# Function to start the Minecraft server
start_server(){
  echo "Starting Minecraft server."
  java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar /minecraft/server/forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui &
  MINECRAFT_PID=$!
}

# Function to gracefully stop the Minecraft server
stop_server(){
  echo "Stopping Minecraft server."
  if [ ! -z "$MINECRAFT_PID" ]; then
    kill -SIGTERM "$MINECRAFT_PID"
  fi
}

# Catch SIGTERM and SIGINT signals and stop the server gracefully
trap stop_server SIGTERM SIGINT

# Main logic
echo "Starting server"
rm -f autostart.stamp
start_server

while true; do
  sleep 10  # Adjust the sleep duration as needed
  
  # Check for the autostop.stamp file to stop the server
  if [ -e autostop.stamp ]; then
    echo "autostop.stamp found. Stopping server."
    rm -f autostop.stamp
    stop_server
    break  # Exit the loop and script
  fi
  
  # Check for autostart.stamp to restart the server
  if [ -e autostart.stamp ]; then
    echo "autostart.stamp found. Restarting server."
    rm -f autostart.stamp
    stop_server
    sleep 5  # Wait for the server to shut down completely
    start_server
    echo "Server process restarted"
  fi
done

# Keep script running to maintain trap
wait $!
