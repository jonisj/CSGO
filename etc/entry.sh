#!/bin/bash
bash "${STEAMCMDDIR}/steamcmd.sh" +login anonymous \
				+force_install_dir "${STEAMAPPDIR}" \
				+app_update "${STEAMAPPID}" \
				+quit

# Are we in a metamod container?
if [ ! -z "$METAMOD_VERSION" ]; then
	LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)

	# Check if metamod needs to be updated or installed
	if [ ! -f "${STEAMAPPDIR}/metamod.version" ] || [ "$LATESTMM" != $(cat "${STEAMAPPDIR}/metamod.version") ]; then
		# Save current Metamod version
		echo "$LATESTMM" >> "${STEAMAPPDIR}/metamod.version"

		# Install Metamod
		echo "Installing MM" ${METAMOD_VERSION}
		wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"	
		echo "Done"
	fi


	if [ ! -z "$SOURCEMOD_VERSION" ]; then
		LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)

		if [ ! -f "${STEAMAPPDIR}/sourcemod.version" ]; then
			# Save current Sourcemod version
			echo "$LATESTSM" >> "${STEAMAPPDIR}/sourcemod.version"

			# Install Sourcemod
			echo "Installing SM" ${SOURCEMOD_VERSION}
			wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
			echo "Done"

		elif [ "$LATESTSM" != $(cat "${STEAMAPPDIR}/sourcemod.version") ]; then
			# Update
			echo "Updating SM" ${SOURCEMOD_VERSION}
			LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
			wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - "addons/sourcemod/bin" "addons/sourcemod/extensions" \
						"addons/sourcemod/gamedata" "addons/sourcemod/translations" "addons/sourcemod/plugins" -C "${STEAMAPPDIR}/${STEAMAPP}"
			echo "Done"
		fi
	fi
fi

# Create a basic config that is run on server launch
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
EOF

if [ -n "$1" ] && [ $1 = "start" ]; then
	bash "./start.sh"
fi
