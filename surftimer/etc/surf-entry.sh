
mkdir -p ${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/ \
		${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/ \
		${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/

# Download and extract dependencies
# DHooks
wget -qO- "https://github.com/peace-maker/DHooks2/releases/download/${DHOOKS_VERSION}-detours15/dhooks-${DHOOKS_VERSION}-detours15-sm110.zip" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"

# SteamWorks
wget -qO- "https://github.com/KyleSanderson/SteamWorks/releases/download/${STEAMWORKS_VERSION}/package-lin.tgz" | tar xzf - "package/addons/sourcemod/extensions/" -C "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"

# SMLib
wget -qO- "https://github.com/bcserv/smlib/archive/${SMLIB_VERSION}.zip" | tar xzf - "smlib-${SMLIB_VERSION}/gamedata/" -C "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/"

# Discord API
wget -qO- "https://github.com/surftimer/Surftimer-Official/releases/download/${SURFTIMER_VERSION}/discord_api.smx" | tar xzf - "${STEAMAPPDIR}/${STEAMAPP}addons/sourcemod/plugins/" -C "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"


# Download and extract Stripper: Source
wget -qO- "http://www.bailopan.net/stripper/files/stripper-${STRIPPER_VERSION}-linux.tar.gz" | tar xzf - -C "${STEAMAPPDIR}/${STEAMAPP}"


# Download SurfTimer
wget -qO- "https://github.com/surftimer/Surftimer-Official/releases/download/${SURFTIMER_VERSION}/SurfTimer.smx" | tar xzf - "${STEAMAPPDIR}/${STEAMAPP}addons/sourcemod/plugins/" -C "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"


# Setup database settings
sed -i -e 's/{{DB_HOST}}/'"${DB_HOST}"'/g' \
		-e 's/{{DB_PORT}}/'"${DB_PORT}"'/g' \
		-e 's/{{DB_PORT}}/'"${DB_DATABASE}"'/g' \
		-e 's/{{DB_PORT}}/'"${DB_USER}"'/g' \
		-e 's/{{DB_PORT}}/'"${DB_PASS}"'/g' \
		"databases.cfg"

mv "databases.cfg" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/databases.cfg"

bash "./start.sh"
