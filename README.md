# Minecraft and Docker

This repository contains the docker compose files related to my minecraft servers and the information needed to install a minecraft server in a linux machine using commands and also interacting with the mc-server console.

## Getting Started

These instructions will give you a copy of the project up and running on
your local machine for development and testing purposes. See deployment
for notes on deploying the project on a live system.

### Installing

Installing docker-compose in Linux:

    sudo apt update -y
    sudo apt install docker-compose -y

Installing the docker container with docker-compose:

    sudo docker compose up -d

Follow the steps here to use docker as non-root user if needed : https://docs.docker.com/engine/install/linux-postinstall/

Other important commands

    # Create and install docker container (force reinstallation if needed)
    docker compose up -d --force-recreate

    # Stop server_name container
    docker stop server_name

    # Start server_name container
    docker start server name

    # Restart server_name container
    docker restart server name

    # Remove server_name container
    docker rm server_name

    # List docker containers
    docker ps

    # Create network
    docker network create

    # List docker images
    docker images

    # Remove image
    docker rmi image_name

    ...

## Deployment

All the docker-compose files are being deployed with docker compose in a Ubuntu server machine.

The Type of servers is Fabric mainly, I started with spigot but migrated all the servers to Fabric now.

Portainer is recommended to access the console of the server and to easly view the logs.

## Send commands to server console

From the ubuntu instance you can send commands into docker container with the following command:

    docker exec -i mc rcon-cli

Examples:

    docker exec -i mc rcon-cli op user

## Sites of interest
- To download the mods for the server:
    https://modrinth.com/
- Geyser/Floodgate to allow compatibility between Java and Bedrock
    https://geysermc.org/
- Complementary Shaders to have a more beutiful minecraft (subjective)
    https://www.complementary.dev/shaders/
- Several Resource packs
    https://www.curseforge.com/minecraft/search?class=texture-packs
