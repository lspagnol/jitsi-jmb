#!/bin/bash

########################################################################
# Autorisation sur attibuts LDAP
########################################################################

# Vérifier si la demande de création est faite par un utilisateur
# autorisé par un filtre LDAP -> variable "JMB_LDAP_FILTER"

$JMB_LDAPSEARCH "(&(uid=${auth_uid})(${JMB_LDAP_FILTER}))" uid |grep -q "^uid: ${auth_uid}$"

if [ ${?} -ne 0 ] ; then
	# L'identifiant ne correspond pas aux critères demandés
	http_403 "Le filtre LDAP ne vous autorise pas à démarrer une réunion"
fi
