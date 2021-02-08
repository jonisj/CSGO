FROM jonisj/csgo-sourcemod

# Surftimer
# https://github.com/surftimer/Surftimer-Official/releases

# Dependencies
# DHooks: https://github.com/peace-maker/DHooks2/releases/latest
# SteamWorks: https://github.com/KyleSanderson/SteamWorks/releases/latest
# SMLib: https://github.com/bcserv/smlib/tags
# Stripper: Source: https://forums.alliedmods.net/showthread.php?t=39439
# SMJansson: https://github.com/thraaawn/SMJansson


ENV DHOOKS_VERSION="2.2.0-detours16" \ 
	STEAMWORKS_VERSION="1.2.3c" \
	SMLIB_VERSION="0.11" \
	STRIPPER_VERSION="1.2.2-git129" \
	SURFTIMER_VERSION="1.0.2" \
	DB_HOST="" \
	DB_PORT="3306" \
	DB_DATABASE="" \
	DB_USER="" \
	DB_PASS="" \
	MAPLIST_URL="" \
	ZONED_MAPS_ONLY=""

USER root
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		unzip \
		default-mysql-client \
		bzip2 \
	&& rm -rf /var/lib/apt/lists/* 
USER steam

COPY "etc/surf-entry.sh" "${HOMEDIR}/surf-entry.sh"

CMD ["surf-entry.sh"]