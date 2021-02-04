#!/bin/bash
set -e

bash "${STEAMCMDDIR}/steamcmd.sh" +login anonymous \
				+force_install_dir "${STEAMAPPDIR}" \
				+app_update "${STEAMAPPID}" \
				+quit


mkdir -p "${DEPVERSIONDIR}"

function checkVersion {
	local -r dependecy="$1"
	local -r current_ver="$2"

	if [ ! -z "$current_ver" ]; then

		if [ ! -f "${DEPVERSIONDIR}/${dependecy}.version" ]; then
			echo "install" # Full install
		elif [ "$current_ver" != $(cat "${DEPVERSIONDIR}/${dependecy}.version") ]; then
			echo "update" # Update
		fi
	fi

	return -1
}

# Check if Metamod needs an update
LATESTMM=$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)
case "$(checkVersion "metamod" "$LATESTMM")" in
	"install" | "update")
		# Install Metamod
		echo "Installing MM" ${METAMOD_VERSION}
		wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/"${LATESTMM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"	
		echo "Done"

		echo "$LATESTMM" > "${DEPVERSIONDIR}/metamod.version"
		;;

	*)
		echo "Metamod is up-to-date"
		;;
esac

# Check if Sourcemod needs an update
LATESTSM=$(wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/sourcemod-latest-linux)
case "$(checkVersion "sourcemod" "$LATESTSM")" in
	"install")
		# Install Sourcemod
		echo "Installing SM" ${SOURCEMOD_VERSION}
		wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
		echo "Done"

		echo "$LATESTSM" > "${DEPVERSIONDIR}/sourcemod.version"
		;;

	"update")
		echo "Updating SM" ${SOURCEMOD_VERSION}

		wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}"  \
			| tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"  \
				"addons/sourcemod/bin" "addons/sourcemod/extensions" "addons/sourcemod/gamedata" \
				"addons/sourcemod/translations" "addons/sourcemod/plugins"

		echo "Done"
		echo "$LATESTSM" > "${DEPVERSIONDIR}/sourcemod.version"
		;;
	*)
		echo "Sourcemod is up-to-date"
		;;
esac

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

bash "$1"
