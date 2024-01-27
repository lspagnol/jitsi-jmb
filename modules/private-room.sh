#!/bin/bash

########################################################################
# Salles de réunion "personnelles" (${JMB_DATA}/private_rooms)
########################################################################

# Si une conférence correspond à un identifiant de connexion présent
# dans l'annuaire LDAP, la demande d'activation n'est acceptée que pour
# son propriétaite.

# Le mapping uid <-> room est fait sur le fichier "${JMB_DATA}/private_rooms"

# Rechercher l'identifiant qui correspond au nom de la réunion
uid=$(grep " ${room}$" ${JMB_DATA}/private_rooms |awk '{print $1}')

if [ ! -z "${uid}" ] ; then
	if [ "${uid}" != "${auth_uid}" ] ; then
		http_403 "Vous n'êtes pas le proprétaire de la réunion '${room}'"
	fi
fi
