#!/bin/bash

########################################################################
# Salles de réunion "personnelles" (${JMB_DATA}/private_rooms)
########################################################################

# Si une conférence correspond à un identifiant de connexion présent
# dans l'annuaire LDAP, la demande d'activation n'est acceptée que pour
# son propriétaite.

# Le mapping uid <-> room est fait sur le fichier "${JMB_DATA}/private_rooms"
# "-" est remplacé par "0", "_" est remplacé par "1"

# Rechercher l'identifiant qui correspond au nom de la réunion
uid=$(grep " ${name}$" ${JMB_DATA}/private_rooms |awk '{print $1}')

if [ ! -z "${uid}" ] ; then
	$JMB_LDAPSEARCH mail=${mail_owner} uid |grep -q "^uid: ${uid}$"
	if [ ${?} -ne 0 ] ; then
		http_403_json "vous n'êtes pas le proprétaire de la réunion '${name}'"
	fi
fi
