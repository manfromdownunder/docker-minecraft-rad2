#!/bin/bash

# Validate environment variables, if needed

# Start the Minecraft server
java -Xmx${JAVA_MEMORY_MAX} -Xms${JAVA_MEMORY_MIN} -XX:PermSize=${JAVA_PERM_SIZE} -jar forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar nogui
