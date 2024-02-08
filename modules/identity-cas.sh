#!/bin/bash

########################################################################
# Récupération des infos utilisateur à partir des attributs CAS
########################################################################

# Prérequis pour la récupération d'attributs CAS:
# - le serveur CAS **DOIT** retourner les attributs nécessaires
# - le module d'authentification CAS / Apache **DOIT** être configuré
#   pour prendre en compte les attributs CAS
#   -> directive "CASAuthNHeader CAS_UID" dans la section protégée / CAS

#auth_uid="${HTTP_CAS_UID,,}"
#auth_name="${HTTP_CAS_GIVENNAME^^} ${HTTP_CAS_SN^^}"
#auth_mail="${HTTP_CAS_MAIL,,}"

if [[ "${HTTP_CAS_UID}" =~ ==$ ]] ; then
	auth_uid=$(echo -n "${HTTP_CAS_UID}" |base64 -d)
else
	auth_uid="${HTTP_CAS_UID}"
fi

if [[ "${HTTP_CAS_MAIL,,}" =~ ==$ ]] ; then
	auth_mail=$(echo -n "${HTTP_CAS_MAIL}" |base64 -d)
else
	auth_mail="${HTTP_CAS_MAIL,,}"
fi

if [[ "${HTTP_CAS_GIVENNAME}" =~ ==$ ]] ; then
	auth_givenname=$(echo -n "${HTTP_CAS_GIVENNAME}" |base64 -d)
else
	auth_givenname="${HTTP_CAS_GIVENNAME}"
fi

if [[ "${HTTP_CAS_SN}" =~ ==$ ]] ; then
	auth_sn=$(echo -n "${HTTP_CAS_SN}" |base64 -d)
else
	auth_sn="${HTTP_CAS_SN}"
fi

auth_uid="${auth_uid,,}"
auth_mail=${auth_mail,,}
auth_name="${auth_givenname^^} ${auth_sn^^}"
