# Use a minimal Debian base image
FROM debian:bullseye-slim

# Set build-time variables
ARG JAVA_VERSION="temurin-8-jdk"

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

# Install initial dependencies and tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    git \
    curl \
    unzip \
    tar \
    nano \
    logrotate \
    gnupg2 \
    apt-transport-https \
    libdl.so.2 \
    libpthread.so.0 \
    libgobject-2.0.so.0 \
    libglib-2.0.so.0 \
    libnss3.so \
    libnssutil3.so \
    libsmime3.so \
    libnspr4.so \
    libatk-1.0.so.0 \
    libatk-bridge-2.0.so.0 \
    libcups.so.2 \
    libgio-2.0.so.0 \
    libdrm.so.2 \
    libdbus-1.so.3 \
    libexpat.so.1 \
    libxcb.so.1 \
    libxkbcommon.so.0 \
    libm.so.6 \
    libX11.so.6 \
    libXcomposite.so.1 \
    libXdamage.so.1 \
    libXext.so.6 \
    libXfixes.so.3 \
    libXrandr.so.2 \
    libgbm.so.1 \
    libpango-1.0.so.0 \
    libcairo.so.2 \
    libasound.so.2 \
    libatspi.so.0 \
    libgcc_s.so.1 \
    libc.so.6 \
    # (include other libraries) && \
    mkdir -p /etc/apt/keyrings && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends $JAVA_VERSION && \
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    apt-get install -y libatk1.0-0 libnss3 libxss1 libasound2 libpangocairo-1.0-0 libcups2 libxrandr2 libgbm1 libatk-bridge2.0-0 libxkbcommon0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for the Minecraft server
WORKDIR /minecraft-server

# Clone the install repo, download mods and perform cleanup
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
    { \
        echo "enable-rcon=${RCON_ENABLED}"; \
        echo "rcon.password=${RCON_PASSWORD}"; \
        echo "rcon.port=${RCON_PORT}"; \
        echo "difficulty=${DIFFICULTY}"; \
        echo "gamemode=${GAMEMODE}"; \
        echo "hardcore=${HARDCORE}"; \
        echo "level-name=${LEVEL_NAME}"; \
        echo "level-seed=${LEVEL_SEED}"; \
        echo "max-build-height=${MAX_BUILD_HEIGHT}"; \
        echo "max-players=${MAX_PLAYERS}"; \
        echo "motd=${MOTD}"; \
        echo "player-idle-timeout=${PLAYER_IDLE_TIMEOUT}"; \
        echo "prevent-proxy-connections=${PREVENT_PROXY_CONNECTIONS}"; \
        echo "pvp=${PVP}"; \
        echo "snooper-enabled=${SNOOPER_ENABLED}"; \
        echo "view-distance=${VIEW_DISTANCE}"; \
        echo "allow-flight=${ALLOW_FLIGHT}"; \
        echo "allow-nether=${ALLOW_NETHER}"; \
    } > server.properties

# Copy the start-server script into the image
COPY start-server.sh /minecraft-server/start-server.sh

# Make the script executable
RUN chmod +x /minecraft-server/start-server.sh

# Expose the Minecraft server port and RCON port
EXPOSE $SERVER_PORT $RCON_PORT

# Start the Minecraft server via the script
CMD ["/minecraft-server/start-server.sh"]

