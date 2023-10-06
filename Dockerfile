# Use a minimal Debian base image
FROM debian:bullseye-slim

# Set build-time variables
ARG JAVA_VERSION="openjdk-8-jre-headless"

# Set default environment variables
ENV MINECRAFT_VERSION="1.16.5" \
    SERVER_PORT="25565" \
    MODPACK_URL="https://www.curseforge.com/minecraft/modpacks/roguelike-adventures-and-dungeons-2" \
    JAVA_MEMORY_MAX="10000m" \
    JAVA_MEMORY_MIN="8000m" \
    JAVA_PERM_SIZE="256m" \
    FORGE_VERSION="36.2.39" \
    RCON_ENABLED="true" \
    RCON_PASSWORD="yourpassword" \
    RCON_PORT="25575" \
    DIFFICULTY="normal" \
    GAMEMODE="survival" \
    HARDCORE="false" \
    LEVEL_NAME="world" \
    LEVEL_SEED="manfromdowunder" \
    MAX_BUILD_HEIGHT="256" \
    MAX_PLAYERS="5" \
    MOTD="R.A.D. 2 Server" \
    PLAYER_IDLE_TIMEOUT="0" \
    PREVENT_PROXY_CONNECTIONS="false" \
    PVP="true" \
    SNOOPER_ENABLED="true" \
    VIEW_DISTANCE="7" \
    ALLOW_FLIGHT="true" \
    ALLOW_NETHER="true"

# Install dependencies
RUN echo 'deb http://deb.debian.org/debian bullseye main' >> /etc/apt/sources.list && \
    echo 'deb http://security.debian.org/debian-security bullseye-security main' >> /etc/apt/sources.list && \
    echo 'deb http://deb.debian.org/debian bullseye-updates main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y software-properties-common && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends $JAVA_VERSION wget git curl unzip tar nano logrotate && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for the Minecraft server
WORKDIR /minecraft-server

# Clone the install repo
RUN git clone https://github.com/manfromdownunder/docker-minecraft-rad2.git && \
    cp docker-minecraft-rad2/downloadmods.sh . && \
    cp docker-minecraft-rad2/modslist.txt . && \
    cp docker-minecraft-rad2/downloadFromCurseForge.js . && \
    chmod +x ./downloadmods.sh && \
    ./downloadmods.sh modslist.txt && \
    rm -rf docker-minecraft-rad2 && \
    rm -rf minecraft && \
    rm -rf binaries

# Accept the Minecraft EULA and configure server properties
RUN echo "eula=true" > eula.txt && \
    echo "enable-rcon=${RCON_ENABLED}" >> server.properties && \
    echo "rcon.password=${RCON_PASSWORD}" >> server.properties && \
    echo "rcon.port=${RCON_PORT}" >> server.properties && \
    echo "difficulty=${DIFFICULTY}" >> server.properties && \
    echo "gamemode=${GAMEMODE}" >> server.properties && \
    echo "hardcore=${HARDCORE}" >> server.properties && \
    echo "level-name=${LEVEL_NAME}" >> server.properties && \
    echo "level-seed=${LEVEL_SEED}" >> server.properties && \
    echo "max-build-height=${MAX_BUILD_HEIGHT}" >> server.properties && \
    echo "max-players=${MAX_PLAYERS}" >> server.properties && \
    echo "motd=${MOTD}" >> server.properties && \
    echo "player-idle-timeout=${PLAYER_IDLE_TIMEOUT}" >> server.properties && \
    echo "prevent-proxy-connections=${PREVENT_PROXY_CONNECTIONS}" >> server.properties && \
    echo "pvp=${PVP}" >> server.properties && \
    echo "snooper-enabled=${SNOOPER_ENABLED}" >> server.properties && \
    echo "view-distance=${VIEW_DISTANCE}" >> server.properties && \
    echo "allow-flight=${ALLOW_FLIGHT}" >> server.properties && \
    echo "allow-nether=${ALLOW_NETHER}" >> server.properties

# Expose the Minecraft server port and RCON port
EXPOSE $SERVER_PORT $RCON_PORT

# Start the Minecraft server
CMD ["java", "-Xmx${JAVA_MEMORY_MAX}", "-Xms${JAVA_MEMORY_MIN}", "-XX:PermSize=${JAVA_PERM_SIZE}", "-jar", "forge-${MINECRAFT_VERSION}-${FORGE_VERSION}.jar", "nogui"]
