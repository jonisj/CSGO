#!/bin/bash
set -e

source ./checkversion.sh

## Prepare MySQL configs
function prepareMySQLClientConfigs {
	# Setup config for mysql client
	MYSQL_CONFIG="$TEMPDIR/mysql.conf"
	cat > "$MYSQL_CONFIG" <<-EOF
		[client]
		host="${DB_HOST}"
		database="${DB_DATABASE}"
		user="${DB_USER}"
		password="${DB_PASS}"
		port="${DB_PORT}"
		EOF

	# Setup Sourcemod's databases.cfg
	cat > "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/databases.cfg" <<-EOF
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
}


## Downloads & Installs SurfTimer's dependencies
function downloadDependencies {
	echo ">>>> Installing SurfTimer's dependencies"

	# Install DHooks2
	case "$(checkVersion "dhooks" "${DHOOKS_VERSION}")" in
		"install" | "update")
			echo ">> Installing DHooks2 ${DHOOKS_VERSION}"
			getZippedDependency "$TEMPDIR" "dhooks" "https://github.com/peace-maker/DHooks2/releases/download/v${DHOOKS_VERSION}/dhooks-${DHOOKS_VERSION}-sm110.zip"
			cp -R "$TEMPDIR/dhooks/addons/sourcemod/gamedata/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/"
			cp -R "$TEMPDIR/dhooks/addons/sourcemod/extensions/"*".so" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"

			updateVersion "dhooks" "$DHOOKS_VERSION"
			;;

		*)
			echo ">> DHooks2 is up-to-date"
			;;
	esac

	# Install SteamWorks
	case "$(checkVersion "steamworks" "${STEAMWORKS_VERSION}")" in
		"install" | "update")
			echo ">> Installing SteamWorks ${STEAMWORKS_VERSION}"
			getTarredDependency "$TEMPDIR" "steamworks" "https://github.com/KyleSanderson/SteamWorks/releases/download/${STEAMWORKS_VERSION}/package-lin.tgz"
			cp -R "$TEMPDIR/steamworks/package/addons/sourcemod/extensions/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"
			
			updateVersion "steamworks" "$STEAMWORKS_VERSION"
			;;

		*)
			echo ">> SteamWorks is up-to-date"
			;;
	esac

	# Install SMLib
	case "$(checkVersion "smlib" "${SMLIB_VERSION}")" in
		"install" | "update")
			echo ">> Installing SMLib ${SMLIB_VERSION}"
			getTarredDependency "$TEMPDIR" "smlib" "https://github.com/bcserv/smlib/archive/${SMLIB_VERSION}.tar.gz"
			cp -R "$TEMPDIR/smlib/smlib-${SMLIB_VERSION}/gamedata/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/"
			
			updateVersion "smlib" "$SMLIB_VERSION"
			;;

		*)
			echo ">> SMLib is up-to-date"
			;;
	esac

	# Install Stripper: Source
	case "$(checkVersion "stripper" "${STRIPPER_VERSION}")" in
		"install" | "update")
			echo ">> Installing Stripper: Source ${STRIPPER_VERSION}"
			getTarredDependency "$TEMPDIR" "stripper" "http://www.bailopan.net/stripper/snapshots/1.2/stripper-${STRIPPER_VERSION}-linux.tar.gz"
			cp -R "$TEMPDIR/stripper/addons/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/"
			
			updateVersion "stripper" "$STRIPPER_VERSION"
			;;

		*)
			echo ">> Stripper: Source is up-to-date"
			;;
	esac

	# Install SMJansson
	case "$(checkVersion "smjansson" "${SMJANSSON_VERSION}")" in
		"install" | "update")
			echo ">> Installing SMJansson ${SMJANSSON_VERSION}"
			getTarredDependency "$TEMPDIR" "smjansson" "https://github.com/thraaawn/SMJansson/archive/${SMJANSSON_VERSION}.tar.gz" 
			cp -R "$TEMPDIR/smjansson/SMJansson-${SMJANSSON_VERSION}/bin/"*".so" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/extensions/"

			updateVersion "smjansson" "$SMJANSSON_VERSION"
		;;

		*)
			echo ">> SMJansson is up-to-date"
			;;
	esac

	# Install Movement Unlocker
	if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/csgo_movement_unlocker.smx" ]; then 
		echo ">> Installing latest Movement Unlocker"
		wget -q "http://www.sourcemod.net/vbcompiler.php?file_id=141520" -O "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/csgo_movement_unlocker.smx"
		wget -q "https://forums.alliedmods.net/attachment.php?attachmentid=141521&d=1495261818" -O "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/gamedata/csgo_movement_unlocker.games.txt"
	fi

	echo ''
}

## Install SurfTimer
function installSurftimer {
	echo ">>>> Installing SurfTimer"
	case "$(checkVersion "surftimer" "${SURFTIMER_VERSION}")" in
		"install" | "update")
			echo ">> Installing SurfTimer ${SURFTIMER_VERSION}"
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
			mysql --defaults-file="$MYSQL_CONFIG" < "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/scripts/mysql-files/ck_maptier.sql"
			mysql --defaults-file="$MYSQL_CONFIG" < "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/scripts/mysql-files/ck_zones.sql"

			# Overwrite default Stripper: Source global_config.cfg
			cp "$TEMPDIR/surftimer/Surftimer-Official-${SURFTIMER_VERSION}/addons/stripper/global_filters.cfg" "${STEAMAPPDIR}/${STEAMAPP}/addons/stripper/global_filters.cfg"
			;;
		*)
			echo ">> SurfTimer is up-to-date"
			;;
	esac
	echo ''
}

## Download maps
function downloadMaps {
	# If fastDL URL and a maplist URL is set, download maps
	if [ ! -z "$SV_DOWNLOADURL" ] && [ ! -z "$MAPLIST_URL" ]; then
		echo ">>>> Downloading Maps & Setting mapcycle.txt"

		local -r maplist_dir="$TEMPDIR/maplist"
		local -r maps_download_dir="$maplist_dir/maps"
		local -r remote_maplist="$maplist_dir/maps.txt"
		local -r mapcycle="$maplist_dir/mapcycle.txt"

		mkdir -p "$maps_download_dir"
		touch "$mapcycle"

		# Download maplist
		wget -qO- "$MAPLIST_URL" > "$remote_maplist"
		
		if [ ! -z "$(grep ".bsp" "$remote_maplist")" ]; then

			if [ ! -z "$ZONED_MAPS_ONLY" ]; then
				# Get all zoned maps from the databse
				zoned_maps=($(mysql --defaults-file="$MYSQL_CONFIG" -se "SELECT mapname FROM ck_zones GROUP BY mapname ORDER BY mapname ASC;"))
			fi

			# Loop through the maplist 
			while IFS="" read -r map || [ -n "$map" ]
			do
				# Get map name without extension
				map_name=$(echo "${map%%.*}")

				if [ ! -z "$ZONED_MAPS_ONLY" ]; then
					# Check if the map is not found from the list of zoned maps
					if [[ ! " ${zoned_maps[@]} " =~ " ${map_name} " ]]; then
						echo "> $map_name not zoned. Skipping."
						continue;
					fi
				fi

				# Check if the map is found on the volume
				if [ ! -f "${STEAMAPPDIR}/${STEAMAPP}/maps/$map_name.bsp" ]; then

					# Download the map
					echo "> Downloading $map"
					wget -q "$SV_DOWNLOADURL/maps/$map" -P "${maps_download_dir}"

					if [[ $map == *.bz2 ]]; then
						echo "> Decompressing"
						bunzip2 -q "${maps_download_dir}/$map"
					fi

					mv "${maps_download_dir}/$map_name.bsp" "${STEAMAPPDIR}/${STEAMAPP}/maps/"
				fi

				# Add map to the mapcycle
				echo $map_name >> "$mapcycle"
			done < "$remote_maplist"

			# Copy mapcycle
			cp "$mapcycle" "${STEAMAPPDIR}/${STEAMAPP}/"
		fi
		echo ''
	fi
}

function installUMC {
	if [ ! -z "$UMC_VERSION" ]; then
		echo ">>>> Installing Ultimate Map Chooser"
		
		case "$(checkVersion "umc" "${UMC_VERSION}")" in
			"install" | "update")
				echo ">> Installing UMC ${UMC_VERSION}"
				getTarredDependency "$TEMPDIR" "umc" "https://github.com/Silenci0/UMC/archive/${UMC_VERSION}.tar.gz"

				# Copy compiled plugins
				# https://github.com/Silenci0/UMC/wiki#umc-modules
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-core.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-adminmenu.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-rockthevote.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-timelimits.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-votecommand.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-endvote-warnings.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-endvote.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-mapcommands.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-nominate.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-playercountmonitor.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-playerlimits.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-postexclude.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-prefixexclude.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-randomcycle.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-master/addons/sourcemod/plugins/nativevotes.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-weight.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-maprate-reweight.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-nativevotes.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"
				#cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/plugins/umc-echonextmap.smx" "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/plugins/"

				# Translations
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/translations/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/translations/"

				echo "$SURFTIMER_VERSION" > "${DEPVERSIONDIR}/umc.version"
				;;&

			"install")
				# Copy configs only during install
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/addons/sourcemod/configs/"* "${STEAMAPPDIR}/${STEAMAPP}/addons/sourcemod/configs/"
				cp -R "$TEMPDIR/umc/UMC-${UMC_VERSION}/cfg/"* "${STEAMAPPDIR}/${STEAMAPP}/cfg/"
				;;
			*)
				echo ">> UMC is up-to-date"
				;;
		esac

		if [ ! -z "$GENERATE_UMC_MAPCYCLE" ]; then
			echo ">> Generating umc_mapcycle.txt"

			local -r mapcycle="${STEAMAPPDIR}/${STEAMAPP}/mapcycle.txt"

			if [ ! -f "$mapcycle" ]; then
				echo "mapcycle.txt not found when trying to create umc-mapcycle!"
				exit -1
			fi

			# Start the umc_mapcycle
			local -r umc_mapcycle="$TEMPDIR/umc/umc_mapcycle.txt"
			cat > "$umc_mapcycle" <<-EOF
			"umc_mapcycle"
			{
			EOF

			# Get all zoned maps and their info from the database
			local -r query="""
			SELECT z.mapname, COUNT(CASE WHEN z.zonetype = 3 THEN 1 ELSE NULL END)+1, IFNULL(t.tier, '?'), count(DISTINCT z.zonegroup)-1
			FROM ck_zones z
			LEFT JOIN ck_maptier t
			ON z.mapname = t.mapname
			GROUP BY z.mapname
			ORDER BY t.tier, z.mapname ASC;
			"""

			# Make a temp variable for checking tiers
			local old_tier=""

			# loop through all the maps
			mysql --defaults-file="$MYSQL_CONFIG" --batch -se "$query" | while read mapname stages tier bonuses; do

				#  Make sure the map is in the mapcycle
				if [ ! -z "$(grep "$mapname" "$mapcycle")" ]; then

					# Check if the map is in a new tier
					if [ "$old_tier" != "$tier" ]; then

						# Close earlier tier, if this is a new one
						if [ ! -z "$old_tier" ]; then
							echo -e '\t}' >> "$umc_mapcycle"
						fi
						echo -e '\t"Tier '"$tier"'"' >> "$umc_mapcycle"
						echo -e '\t{' >> "$umc_mapcycle"


						old_tier=$tier
					fi

					# Label for stages & bonuses
					stage_label=" L"
					if [ "$stages" -gt 1 ]; then
						stage_label=" ${stages}S"
					fi

					bonus_label=""
					if [ "$bonuses" -gt 0 ]; then
						bonus_label=" ${bonuses}B"
					fi

					echo -e '\t\t"'$mapname'"		{ "display"		"'$mapname' (T'$tier''$stage_label''$bonus_label')" }' >> "$umc_mapcycle"

				fi
			done

			# Close file
			cat >> "$umc_mapcycle" <<-EOF
				}
			}
			EOF

			mv $umc_mapcycle "${STEAMAPPDIR}/${STEAMAPP}/"
		fi
	fi
}


function cleanup {
	rm -rf "$TEMPDIR" 
}

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


function startServer {
	echo "Starting server..."
	echo "------------------------------------------"

	bash "./start.sh"
}

function setupServer {
	## Create a temp directory and setup cleaning
	TEMPDIR="$(mktemp -d)"
	trap cleanup EXIT

	prepareMySQLClientConfigs
	downloadDependencies
	installSurftimer
	downloadMaps
	installUMC

	cleanup

	startServer
}

setupServer
