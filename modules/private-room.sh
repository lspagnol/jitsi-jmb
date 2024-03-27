#!/bin/bash

########################################################################
# Salles de réunion "personnelles" (${JMB_DATA}/private_rooms)
########################################################################

if [ "${allow}" = "1" ] ; then

	# Déjà validé -> rien à faire
	log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='private-room.sh': ok (already allowed)"

else

	# Si le nom de la réuion correspond à un identifiant de connexion
	# présent dans la table "private_rooms", la demande d'activation
	# n'est acceptée que pour son propriétaire.

	if [ "${room}" = "${auth_uid}" ] ; then
		log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='private-room.sh': allow"
		# MAJ compteur et date
		count=$(sqlite3 ${JMB_DB} "SELECT private_count FROM private WHERE private_room='${room}';")
		if [ -z "${count}" ] ; then
			sqlite3 ${JMB_DB} "INSERT INTO private (private_room,private_count,private_date) VALUES ('${room}','1','${now}');"
		else
			((count++))
			sqlite3 ${JMB_DB} "UPDATE private SET private_count='${count}',private_date='${now}' WHERE private_room='${room}';"
		fi
		allow=1
	else
		log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='private-room.sh': DENIED (not owner)"
		http_403 "Vous n'êtes pas proprétaire de la réunion privée '${room}'"
	fi

fi
