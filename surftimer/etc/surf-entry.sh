#!/bin/bash
set -e

## Create a temp directory and setup cleaning
TEMPDIR="$(mktemp -d)"

function cleanup {
	rm -rf "$TEMPDIR" 
}

trap cleanup EXIT

## Functions for downloading dependencies
function getZippedDependency {
	local -r dest="$1"
	local -r name="$2"
	local -r url="$3"
	
	mkdir -p "$dest/$name"

	wget -qO- "$url" > "$dest/$name.zip"
	unzip -oq "$dest/$name.zip" -d "$dest/$name/"

	rm -rf "$dest/$name.zip"
}

function getTarredDependency {
	local -r dest="$1"
	local -r name="$2"
	local -r url="$3"
	
	mkdir -p "$dest/$name"

	wget -qO- "$url" > "$dest/$name.tar.gz"
	tar xzf "$dest/$name.tar.gz" -C "$dest/$name/"

	rm -rf "$dest/$name.tar.gz"
}

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

## Download & Install SurfTimer's dependencies
# Install DHooks2
case "$(checkVersion "dhooks" "${DHOOKS_VERSION}")" in
	"install" | "update")
		getZippedDependency "$TEMPDIR" "dhooks" "https://github.com/peace-maker/DHooks2/releases/download/v${DHOOKS_VERSION}/dhooks-${DHOOKS_VERSION}-sm110.zip"
		cp -R "$TEMPDIR/dhooks/addons/sourcemod/gamedata/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/"
		cp -R "$TEMPDIR/dhooks/addons/sourcemod/extensions/"*".so" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"
		
		echo "$DHOOKS_VERSION" > "${DEPVERSIONDIR}/dhooks.version"
		;;

	*)
		echo "DHooks2 is up-to-date"
		;;
esac

# Install SteamWorks
case "$(checkVersion "steamworks" "${STEAMWORKS_VERSION}")" in
	"install" | "update")
		getTarredDependency "$TEMPDIR" "steamworks" "https://github.com/KyleSanderson/SteamWorks/releases/download/${STEAMWORKS_VERSION}/package-lin.tgz"
		cp -R "$TEMPDIR/steamworks/package/addons/sourcemod/extensions/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"

		echo "$STEAMWORKS_VERSION" > "${DEPVERSIONDIR}/steamworks.version"
		;;

	*)
		echo "SteamWorks is up-to-date"
		;;
esac

# Install SMLib
case "$(checkVersion "smlib" "${SMLIB_VERSION}")" in
	"install" | "update")
		getTarredDependency "$TEMPDIR" "smlib" "https://github.com/bcserv/smlib/archive/${SMLIB_VERSION}.tar.gz"
		cp -R "$TEMPDIR/smlib/smlib-${SMLIB_VERSION}/gamedata/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/"

		echo "${SMLIB_VERSION}" > "${DEPVERSIONDIR}/smlib.version"
		;;

	*)
		echo "SMLib is up-to-date"
		;;
esac

# Install Stripper: Source
case "$(checkVersion "stripper" "${SMLIB_VERSION}")" in
	"install" | "update")
		getTarredDependency "$TEMPDIR" "stripper" "http://www.bailopan.net/stripper/files/stripper-${STRIPPER_VERSION}-linux.tar.gz"
		cp -R "$TEMPDIR/stripper/addons/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/"

		echo "${STRIPPER_VERSION}" > "${DEPVERSIONDIR}/stripper.version"
		;;

	*)
		echo "Stripper: Source is up-to-date"
		;;
esac

# Install SMJansson
getTarredDependency "$TEMPDIR" "smjansson" "https://github.com/thraaawn/SMJansson/archive/master.tar.gz" 
cp -R "$TEMPDIR/smjansson/SMJansson-master/bin/"*".so" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"


## Install SurfTimer
case "$(checkVersion "surftimer" "${SURFTIMER_VERSION}")" in
	"install" | "update")
		echo "Install SurfTimer ${SURFTIMER_VERSION}"
		getTarredDependency "$TEMPDIR" "surftimer" "https://github.com/surftimer/Surftimer-Official/archive/${SURFTIMER_VERSION}.tar.gz"
		
		# Download compiled .smx
		wget -q "https://github.com/surftimer/Surftimer-Official/releases/download/${SURFTIMER_VERSION}/discord_api.smx" -O "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/discord_api.smx"
		wget -q "https://github.com/surftimer/Surftimer-Official/releases/download/${SURFTIMER_VERSION}/SurfTimer.smx" -O "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/SurfTimer.smx"
		
		# Copy extra files
		cp -Rn "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/addons/stripper/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/stripper/"
		cp -Rn "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/addons/sourcemod/configs/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/"
		cp -Rn "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/cfg/"* "${STEAMAPPDIR}/${STEAMAPP}/cfg/"
		
		cp -R "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/addons/sourcemod/translations/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/translations/"
		cp -R "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/maps/"* "${STEAMAPPDIR}/${STEAMAPP}/maps/"
		cp -R "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/sound/"* "${STEAMAPPDIR}/${STEAMAPP}/sound/"

		echo "$SURFTIMER_VERSION" > "${DEPVERSIONDIR}/surftimer.version"
		;;&

	"install")
		##  Run MySQL scripts on first install
		cat > "$TEMPDIR/mysql.conf" <<EOF
[client]
host="${DB_HOST}"
database="${DB_DATABASE}"
user="${DB_USER}"
password="${DB_PASS}"
port="${DB_PORT}"
EOF
		mysql --defaults-file="$TEMPDIR/mysql.conf" < "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/scripts/mysql-files/ck_maptier.sql"
		mysql --defaults-file="$TEMPDIR/mysql.conf" < "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/scripts/mysql-files/ck_zones.sql"
		;;
	*)
		echo "SurfTimer is up-to-date"
		;;
esac


## Download maps
if [ ! -z "$SV_DOWNLOADURL" ] && [ ! -z "$MAPLIST_URL" ]; then
	MAPLIST_DIR="$TEMPDIR/maplist"
	MAPS_DIR="$MAPLIST_DIR/maps"
	MAPLIST="$MAPLIST_DIR/maps.txt"
	MAPCYCLE="$MAPLIST_DIR/mapcycle.txt"

	mkdir -p "$MAPS_DIR"
	
	touch "$MAPCYCLE"

	# Download maplist
	wget -qO- "$MAPLIST_URL" > "$MAPLIST"

	if [ ! -z "$(grep ".bsp" "$MAPLIST")" ]; then

		# Loop through the maplist 
		while IFS="" read -r map || [ -n "$map" ]
		do
			# Get map name without extension
			map_name=$(echo "${map%%.*}")

			# Check if the map is found on the volume
			if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/maps/$map_name.bsp" ]; then
				# Download the map
				echo "Downloading $map"
				wget -q "$SV_DOWNLOADURL/maps/$map" -P "${MAPS_DIR}"
			fi

			# Add map to the mapcycle
			echo $map_name >> "$MAPCYCLE"
		done < "$MAPLIST"

		echo "Extracting maps.."
		bunzip2 -q "${MAPS_DIR}/"*".bz2" 2>/dev/null
		echo "Done"

		# Copy mapcycle & downloaded maps
		cp "$MAPCYCLE" "${STEAMAPPDIR}/${STEAMAPP}/"
		cp -R "${MAPS_DIR}/" "${STEAMAPPDIR}/${STEAMAPP}/"
	fi
fi

rm -rf "$TEMPDIR" 

# Setup database config

cat > "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/databases.cfg" <<EOF
"Databases"
{
	"storage-local"
	{
		"driver"			"sqlite"
		"database"			"sourcemod-local"
	}

	"clientprefs"
	{
		"driver"			"sqlite"
		"host"				"localhost"
		"database"			"clientprefs-sqlite"
		"user"				"root"
		"pass"				""
		//"timeout"			"0"
		//"port"			"0"
	}

	"surftimer"
	{
		"driver"			"mysql"
		"host"				"${DB_HOST}"
		"database"			"${DB_DATABASE}"
		"user"				"${DB_USER}"
		"pass"				"${DB_PASS}"
		"port"				"${DB_PORT}"
	}
}
EOF

# Start the server
bash "./start.sh"
