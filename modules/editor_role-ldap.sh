#!/bin/bash

########################################################################
# Vérification du rôle "éditeur" (peut modifier / créer / supprimer)
# Recherche sur uid=${auth_uid} dans LDAP
# JMB_LDAP_FILTER défini dans "jmb.cf" ou "jmb_local.cf"
# Retour: variable "is_editor"
# 0 -> pas éditeur
# 1 -> éditeur
########################################################################

$JMB_LDAPSEARCH "(&(uid=${auth_uid})(${JMB_LDAP_FILTER}))" uid |grep -q '^uid: '
if [ ${?} = 0 ] ; then

	is_editor=1

else

	is_editor=0

fi
