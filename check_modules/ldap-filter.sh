#!/bin/bash

########################################################################
# Autorisation sur attibuts LDAP
########################################################################

# Vérifier si la demande de création est faite par un utilisateur
# autorisé par un filtre LDAP -> etc/ldap-filter.cf
# variable "LDAP_FILTER"

# Récupérer l'identifiant de connexion
uid=$($JMB_LDAPSEARCH mail=${mail_owner} uid |grep "^uid: " |awk '{print $2}')
if [ -z "${uid}" ] ; then
	http_403_json "je ne vous ai pas trouvé dans l'annuaire LDAP"
fi

$JMB_LDAPSEARCH "(&(uid=${uid})(${LDAP_FILTER}))" uid |grep -q "^uid: ${uid}$"

if [ ${?} -ne 0 ] ; then
	# L'identifiant ne correspond pas aux critères demandés
	http_403_json "le filtre LDAP ne vous autorise pas à démarrer une réunion"
fi
