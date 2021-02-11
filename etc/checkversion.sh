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

function updateVersion {
	local -r dependecy="$1"
	local -r new_version="$2"
	if [ ! -z "$dependecy" ] && [ ! -z "$new_version" ]; then
		echo "$new_version" > "${DEPVERSIONDIR}/${dependecy}.version"
	fi
}