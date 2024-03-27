#!/bin/bash

########################################################################
# Réunions planifiées
########################################################################

if [ "${allow}" = "1" ] ; then

	# Déjà validé -> rien à faire
	log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='booking.sh': ok (already allowed)"

else

	# Si la réunion est planifiée, s'assurer qu'elle n'est pas expirée et que
	# la demande d'activation est faite par son propriétaire ou un modérateur
	
	# On récupère les infos de la réunion planifiée
	tsn=$(sqlite3 ${JMB_DB} "SELECT meeting_id FROM meetings WHERE meeting_name='${room}';")

	if [ ! -z "${tsn}" ] ; then

		# La base contient une réservation pour "${room}"

		get_meeting_infos ${tsn}

		# Réunion terminée ?
		if [ ${now} -ge ${end} ] ; then
			log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='booking.sh': DENIED (meeting terminated)"
			http_403 "La réunion '${room}' est terminée"
		fi

		# Utilisateur propriétaire de la réunion ?
		if [ "${owner}" = "${auth_mail}" ] ; then
			log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='booking.sh': allow (owner)"
			allow=1
		else
			# Utilisateur modérateur de la réunion ?
			echo " ${moderators} " |grep -q " ${auth_mail} "
			if [ ${?} -eq 0 ] ; then
				log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='booking.sh': allow (moderator)"
				allow=1
			else
				# L'utilisateur n'est pas modérateur
				log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', role='owner', auth_uid='${auth_uid}', check_module='booking.sh': DENIED (not owner|moderator)"
				http_403 "Vous n'êtes propriétaire ou modérateur de la réunion '${room}'"
			fi

		fi

	fi

fi
