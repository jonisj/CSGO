#!/bin/bash
set -e

source ./checkversion.sh

bash "${STEAMCMDDIR}/steamcmd.sh" +login anonymous \
				+force_install_dir "${STEAMAPPDIR}" \
				+app_update "${STEAMAPPID}" \
				+quit


mkdir -p "${DEPVERSIONDIR}"

# Check if Metamod needs an update
echo ">>>> Installing Metamod"
LATESTMM="$(wget -qO- https://mms.alliedmods.net/mmsdrop/"${METAMOD_VERSION}"/mmsource-latest-linux)"
case "$(checkVersion "metamod" "$LATESTMM")" in
	"install" | "update")
		# Install Metamod"
		echo ">> Installing Metamod ${METAMOD_VERSION}"
		wget -qO- "https://mms.alliedmods.net/mmsdrop/${METAMOD_VERSION}/${LATESTMM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"
		updateVersion "metamod" "$LATESTMM"
		;;

	*)
		echo ">> Metamod is up-to-date"
		;;
esac
echo ''

# Check if Sourcemod needs an update
echo ">>>> Installing Sourcemod"
LATESTSM="$(wget -qO- "https://sm.alliedmods.net/smdrop/${SOURCEMOD_VERSION}/sourcemod-latest-linux")"
case "$(checkVersion "sourcemod" "$LATESTSM")" in
	"install")
		# Install Sourcemod
		echo ">> Installing Sourcemod ${SOURCEMOD_VERSION}"

		wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"

		updateVersion "sourcemod" "$LATESTSM"
		;;

	"update")
		echo ">> Updating Sourcemod ${SOURCEMOD_VERSION}"

		wget -qO- https://sm.alliedmods.net/smdrop/"${SOURCEMOD_VERSION}"/"${LATESTSM}"  \
			| tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"  \
				"addons/sourcemod/bin" "addons/sourcemod/extensions" "addons/sourcemod/gamedata" \
				"addons/sourcemod/translations" "addons/sourcemod/plugins"

		updateVersion "sourcemod" "$LATESTSM" 
		;;
	*)
		echo ">> Sourcemod is up-to-date"
		;;
esac
echo ''

# Create a basic config that is run on server launch
cat > "${STEAMAPPDIR}/${STEAMAPP}/cfg/launch.cfg" <<EOF
hostname "${SRCDS_HOSTNAME}"
log off

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
