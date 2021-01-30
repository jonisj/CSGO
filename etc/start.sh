#!/bin/bash

# Believe it or not, if you don't do this srcds_run shits itself
cd ${STEAMAPPDIR}

bash "${STEAMAPPDIR}/srcds_run" -game "${STEAMAPP}" -console -autoupdate \
			-steam_dir "${STEAMCMDDIR}" \
			-steamcmd_script "${HOMEDIR}/${STEAMAPP}_update.txt" \
			-usercon \
			+fps_max "${SRCDS_FPSMAX}" \
			-tickrate "${SRCDS_TICKRATE}" \
			-port "${SRCDS_PORT}" \
			+tv_port "${SRCDS_TV_PORT}" \
			+clientport "${SRCDS_CLIENT_PORT}" \
			-maxplayers_override "${SRCDS_MAXPLAYERS}" \
			+game_type "${SRCDS_GAMETYPE}" \
			+game_mode "${SRCDS_GAMEMODE}" \
			+mapgroup "${SRCDS_MAPGROUP}" \
			+map "${SRCDS_STARTMAP}" \
			+sv_setsteamaccount "${SRCDS_TOKEN}" \
			+rcon_password "${SRCDS_RCONPW}" \
			+sv_password "${SRCDS_PW}" \
			+sv_region "${SRCDS_REGION}" \
			+net_public_adr "${SRCDS_NET_PUBLIC_ADDRESS}" \
			-ip "${SRCDS_IP}" \
			+host_workshop_collection "${SRCDS_HOST_WORKSHOP_COLLECTION}" \
			+workshop_start_map "${SRCDS_WORKSHOP_START_MAP}" \
			-authkey "${SRCDS_WORKSHOP_AUTHKEY}" \
			+exec "launch.cfg"
			"${ADDITIONAL_ARGS}"