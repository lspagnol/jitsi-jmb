#!/bin/bash

########################################################################
# Salles de réunion "personnelles" (LDAP)
########################################################################

# Si une conférence correspond à un identifiant de connexion présent
# dans l'annuaire LDAP, la demande d'activation n'est acceptée que pour
# son propriétaite.

# ** ATTENTION ** -> ne fonctionne pas pour les uid qui contiennent "-" ou "_"
#                 -> utiliser "private-room.sh"

$JMB_LDAPSEARCH uid=${name} |grep -q "^uid: ${name}$"
if [ ${?} -eq 0 ] ; then
	# Le nom de la salle correspond à un identifiant de connexion
	$JMB_LDAPSEARCH mail=${mail_owner} uid |grep -q "^uid: ${name}$"
	if [ ${?} -ne 0 ] ; then
		http_403_json "vous n'êtes pas le proprétaire de la réunion '${name}'"
	fi
fi
