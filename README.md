# Minecaft Roguelike Adventures and Dungeons 2

This is a docker image for [Roguelike Adventures and Dungeons 2](https://www.curseforge.com/minecraft/modpacks/roguelike-adventures-and-dungeons-2)


## Supported Architectures

Simply pulling `ghcr.io/manfromdownunder/docker-minecraft-rad2:latest` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| arm64 | ✅ | arm64v8-\<version tag\> |
| armhf | ❌ |  |

## Usage

To help you get started creating a container from this image you can either use docker-compose.

### docker-compose

```yaml
---
version: '3'

services:
  rad2_server:
    image: manfromdownunder/docker-minecraft-rad2:latest
    ports:
      - "25565:25565"
      - "25575:25575"
    environment:
      EULA_ACCEPT: "false" #set to true if you accept the EULA
      MINECRAFT_VERSION: "1.16.5"
      SERVER_PORT: "25565"
      MODPACK_URL: "https://www.curseforge.com/minecraft/modpacks/roguelike-adventures-and-dungeons-2"
      JAVA_MEMORY_MAX: "10000m"
      JAVA_MEMORY_MIN: "8000m"
      JAVA_PERM_SIZE: "256m"
      FORGE_VERSION: "36.2.39"
      RCON_ENABLED: "true"
      RCON_PASSWORD: "yourpassword"
      RCON_PORT: "25575"
      DIFFICULTY: "normal"
      GAMEMODE: "survival"
      HARDCORE: "false"
      LEVEL_NAME: "world"
      LEVEL_SEED: "manfromdowunder"
      MAX_BUILD_HEIGHT: "256"
      MAX_PLAYERS: "5"
      MOTD: "R.A.D. 2 Server"
      PLAYER_IDLE_TIMEOUT: "0"
      PREVENT_PROXY_CONNECTIONS: "false"
      PVP: "true"
      SNOOPER_ENABLED: "true"
      VIEW_DISTANCE: "7"
      ALLOW_FLIGHT: "true"
      ALLOW_NETHER: "true"
    volumes:
      - ./world:/minecraft/server/world
      - ./world:/minecraft/server/backups
      - ./logs:/minecraft/server/logs
      - ./control/ops.json:/minecraft/server/ops.json
```

## Versions

* **1.0.0:** - Initial release.
