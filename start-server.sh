#!/bin/bash

echo "Starting Minecraft server."
screen -S minecraft -d -m java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar /minecraft/server/forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui

