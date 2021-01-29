#!/bin/bash
bash "${STEAMCMDDIR}/steamcmd.sh" +login anonymous \
				+force_install_dir "${STEAMAPPDIR}" \
				+app_update "${STEAMAPPID}" \
				+quit

# Are we in a metamod container?
if [ ! -z "$METAMOD_VERSION" ]; then
	echo "Installing fresh MM" ${SOURCEMOD_VERSION}
	LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
	wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"	
	echo "Done"

	if [ ! -z "$SOURCEMOD_VERSION" ]; then

		# We assume that if the config Wis missing, that this is a fresh container
		if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/cfg/launch.cfg" ]; then
			echo "Installing fresh SM" ${SOURCEMOD_VERSION}
			LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
			wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
			echo "Done"
		else
			echo "Updating SM" ${SOURCEMOD_VERSION}
			LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
			wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - "addons/sourcemod/bin" "addons/sourcemod/extensions" \
						"addons/sourcemod/gamedata" "addons/sourcemod/translations" "addons/sourcemod/plugins" -C "${STEAMAPPDIR}/${STEAMAPP}"
			echo "Done"
		fi
	fi
fi

cat > "${STEAMAPPDIR}/${STEAMAPP}/cfg/launch.cfg" <<EOF
hostname "${SRCDS_HOSTNAME}"

log off
sv_log_onefile "0"
sv_logbans "0"
sv_logecho "0"
sv_logfile "0"
sv_logflush "0"
sv_logsdir "logs"

sv_lan "0"
sv_cheats "0"

sv_pausable "0"
sv_allow_votes "0"
sv_allow_wait_command "1"
sv_alltalk "1"
sv_full_alltalk "1"
sv_deadtalk "1"
sv_forcepreload "1"

sv_allowupload 1
sv_allowdownload 1
sv_downloadurl "${SV_DOWNLOADURL}"

bot_quota 0
bot_quota fill
bot_chatter off

mp_warmup_pausetimer 1
mp_warmuptime 99999
mp_do_warmup_period 1
mp_do_warmup_offine 1
mp_maxmoney 60000
mp_startmoney 60000
EOF

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
            -exec "launch.cfg"
			"${ADDITIONAL_ARGS}"