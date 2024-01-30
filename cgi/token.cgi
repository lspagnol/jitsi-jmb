#!/bin/bash

########################################################################
# CGI authentification JWT + autorisation pour l'activation des réunions
########################################################################

# Timestamps
now=$(date +%s)
tsn=$(date +%s%N)

########################################################################

# Charger la configuration et les fonctions
JMB_PATH=/opt/jitsi-jmb
source ${JMB_PATH}/etc/jmb.cf
source ${JMB_PATH}/lib/jmb.lib

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

# Décodage et extraction des données GET
getdecode

# Récupérer les infos utilisateur à partir de l'authentification
source ${JMB_PATH}/modules/${JMB_IDENTITY_MODULE}.sh

########################################################################

# Durée par défaut des conférences
duration=${JMB_DEFAULT_DURATION}

# Période de validité du jeton
exp=$(( ${now} + 5 ))
nbf=$(( ${now} - 5 ))

# Préparation du jeton

header=$(jwt_gen_header)
payload=$(jwt_gen_payload)

header_base64=$(echo "${header}" | jwt_json | jwt_base64_encode)
payload_base64=$(echo "${payload}" | jwt_json | jwt_base64_encode)

header_payload=$(echo "${header_base64}.${payload_base64}")
signature=$(echo "${header_payload}" | jwt_hmacsha256_sign | jwt_base64_encode)

########################################################################

# Retour à l'URL d'origine si un module n'est pas validé
url_redirect="/${room}"

# Modules de vérification
for check_module in ${JMB_CHECK_MODULES} ; do
	[ -f ${JMB_PATH}/modules/${check_module}.cf ] && source ${JMB_PATH}/modules/${check_module}.cf
	[ -f ${JMB_PATH}/modules/${check_module}.sh ] && source ${JMB_PATH}/modules/${check_module}.sh
done

# Auth OK + modules de vérification OK
# -> redirection vers la salle de réunion avec le token JWT en paramètre
#http_302 "/${room}#config.prejoinConfig.enabled=false?jwt=${header_payload}.${signature}"
http_302 "/${room}?jwt=${header_payload}.${signature}"
