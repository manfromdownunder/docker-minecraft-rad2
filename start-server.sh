#!/bin/bash

# Function to read RCON password from server.properties
read_rcon_password(){
  RCON_PASSWORD=$(grep 'rcon.password=' /minecraft/server/server.properties | cut -d'=' -f2)
}

# Function to send RCON commands to Minecraft
send_rcon(){
  mcrcon -c -H localhost -P 25575 -p "$RCON_PASSWORD" "$@"
}

# Function to start the Minecraft server
start_server(){
  echo "Starting Minecraft server."
  java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar /minecraft/server/forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui &
  MINECRAFT_PID=$!
}

# Function to send countdown warnings to players
send_countdown(){
  for i in 5 4 3 2; do
    send_rcon "say Server is $1 in $i minutes!"
    sleep 60
  done
  send_rcon "say Server is $1 in 60 seconds."
  sleep 30
  send_rcon "say Server is $1 in 30 seconds. Please log out now"
  sleep 25
  send_rcon "say Server is $1 in 5 seconds. Please log out now"
  sleep 5
  send_rcon "say Server is $1 now!"
}

# Function to gracefully stop the Minecraft server
stop_server(){
  echo "Stopping Minecraft server."
  send_countdown "shutting down"
  if [ ! -z "$MINECRAFT_PID" ]; then
    kill -SIGTERM "$MINECRAFT_PID"
    wait "$MINECRAFT_PID"  # Wait for the server process to fully exit
  fi
}

# Catch SIGTERM and SIGINT signals and stop the server gracefully
trap stop_server SIGTERM SIGINT

# Main logic
echo "Starting server"
read_rcon_password  # Read the RCON password
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
    send_countdown "restarting"
    stop_server
    sleep 5  # Allow additional time for resources to be released
    start_server
    echo "Server process restarted"
  fi
done

# Keep script running to maintain trap
wait $!
