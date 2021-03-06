Dockerfile that builds a basic CSGO Server with Sourcemod and Metamod.

# How to use this image
## Hosting a simple game server

Running on the *host* interface (recommended):<br/>
```console
$ docker run -d --net=host --name=csgo-dedicated -e SRCDS_TOKEN={YOURTOKEN} jonisj/csgo-sourcemod
```

Running using a bind mount for data persistence on container recreation:
```console
$ mkdir -p $(pwd)/csgo-data
$ chmod 777 $(pwd)/csgo-data # Makes sure the directory is writeable by the unprivileged container user
$ docker run -d --net=host -v $(pwd)/csgo-data:/home/steam/csgo-dedicated/ --name=csgo-dedicated -e SRCDS_TOKEN={YOURTOKEN} jonisj/csgo-sourcemod
```

Running multiple instances (increment SRCDS_PORT and SRCDS_TV_PORT):
```console
$ docker run -d --net=host --name=csgo-dedicated2 -e SRCDS_PORT=27016 -e SRCDS_TV_PORT=27021 -e SRCDS_TOKEN={YOURTOKEN} jonisj/csgo-sourcemod
```

`SRCDS_TOKEN` **is required to be listed & reachable;** [https://steamcommunity.com/dev/managegameservers](https://steamcommunity.com/dev/managegameservers)<br/><br/>
`SRCDS_WORKSHOP_AUTHKEY` **is required to use the workshop;** [https://steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey)<br/><br/>

**It's also recommended to use "--cpuset-cpus=" to limit the game server to a specific core & thread.**<br/>
**The container will automatically update the game on startup, so if there is a game update just restart the container.**

# Configuration
## Environment Variables
Feel free to overwrite these environment variables, using -e (--env): 
```dockerfile
SRCDS_TOKEN="changeme" (value is is required to be listed & reachable, retrieve token here: https://steamcommunity.com/dev/managegameservers)
SRCDS_RCONPW="changeme" (value can be overwritten by csgo/cfg/server.cfg) 
SRCDS_PW="changeme" (value can be overwritten by csgo/cfg/server.cfg) 
SRCDS_PORT=27015
SRCDS_TV_PORT=27020
SRCDS_NET_PUBLIC_ADDRESS="0" (public facing ip, useful for local network setups)
SRCDS_IP="0" (local ip to bind)
SRCDS_FPSMAX=300
SRCDS_TICKRATE=128
SRCDS_MAXPLAYERS=14
SRCDS_STARTMAP="de_dust2"
SRCDS_REGION=3
SRCDS_MAPGROUP="mg_active"
SRCDS_GAMETYPE=0
SRCDS_GAMEMODE=1
SRCDS_HOSTNAME="New CSGO Server"
SRCDS_WORKSHOP_START_MAP=0
SRCDS_HOST_WORKSHOP_COLLECTION=0
SRCDS_WORKSHOP_AUTHKEY="" (required to use host_workshop_map)
ADDITIONAL_ARGS="" (Pass additional arguments to srcds. Make sure to escape correctly!)

SV_DOWNLOADURL="" (Your FastDL URL)

METAMOD_VERSION="1.11"
SOURCEMOD_VERSION="1.11"
```
