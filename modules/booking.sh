#!/bin/bash

########################################################################
# Réunions planifiées
########################################################################

# Si la réunion est planifiée, s'assurer qu'elle n'est pas expirée et que
# la demande d'activation est faite par son propriétaire ou un modérateur

# On récupère les infos de la réunion planifiée
tsn=$(sqlite3 ${JMB_DB} "SELECT meeting_id FROM meetings WHERE meeting_name='${room}';")

if [ ! -z "${tsn}" ] ; then

	# La base contient une réservation pour "${room}"

	get_meeting_infos ${tsn}

	if [ ${now} -ge ${end} ] ; then
		http_403 "La réunion '${room}' est terminée"
	fi

	if [ "${owner}" != "${auth_mail}" ] ; then
		# L'utilisateur n'est pas propriétaire
		echo " ${moderators} " |grep -q " ${auth_mail} "
		if [ ${?} -ne 0 ] ; then
			# L'utilisateur n'est pas modérateur
			http_403 "Vous n'êtes pas propriétaire ou modérateur de la réunion '${room}'"
		fi
	fi

fi
