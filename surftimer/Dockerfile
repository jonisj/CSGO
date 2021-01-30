FROM jonisj/csgo-sourcemod

# Surftimer
# https://github.com/surftimer/Surftimer-Official/releases

# Dependencies
# DHooks: https://github.com/peace-maker/DHooks2/releases/latest
# SteamWorks: https://github.com/KyleSanderson/SteamWorks/releases/latest
# SMLib: https://github.com/bcserv/smlib/tags
# Stripper: Source: https://forums.alliedmods.net/showthread.php?t=39439


ENV DHOOKS_VERSION="2.2.0" \ 
	STEAMWORKS_VERSION="1.2.3c" \
	SMLIB_VERSION="0.11" \
	STRIPPER_VERSION="1.2.2" \
	SURFTIMER_VERSION="285" \
	DB_HOST="" \
	DB_PORT="3306" \
	DB_DATABASE="" \
	DB_USER="" \
	DB_PASS=""

COPY "etc/" .

CMD ["bash", "surf-entry.sh"]

