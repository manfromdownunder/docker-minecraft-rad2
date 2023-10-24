#!/bin/bash

start_server(){
echo "Starting Minecraft server."
screen -S minecraft -d -m java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar /minecraft/server/forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui
}

echo "Starting server"
rm -f autostart.stamp
start_server

while [ -e autostart.stamp ] ; do
    rm -f autostart.stamp
    echo "If you want to completely stop the server process now, press Ctrl+C before the time is up!"
    for i in 5 4 3 2 1; do
        echo "Restarting server in $i"
        sleep 1
    done
    echo "Rebooting now!"
    start_server
    echo "Server process finished"
done