#!/bin/bash

########################################################################
# Autorisation sur attibuts LDAP
########################################################################

# Vérifier si la demande de création est faite par un utilisateur
# autorisé par un filtre LDAP -> variable "JMB_MODULE_CHECK_EDITOR_LDAP_FILTER"

$JMB_LDAPSEARCH "(&(uid=${auth_uid})(${JMB_MODULE_CHECK_EDITOR_LDAP_FILTER}))" uid |grep -q "^uid: ${auth_uid}$"

if [ ${?} -ne 0 ] ; then
	# L'identifiant ne correspond pas aux critères demandés
	log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='ldap-filter.sh': DENIED (not editor)"
	http_403 "Le filtre LDAP ne vous autorise pas à démarrer une réunion"
fi

log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}', check_module='ldap-filter.sh': ok"
