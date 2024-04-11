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

# Décodage et extraction des données GET ("room=" passé dans l'URL)
getdecode

# Récupérer les infos utilisateur à partir de l'authentification
source ${JMB_PATH}/modules/${JMB_MODULE_GET_AUTH_IDENTITY}

########################################################################

# Période de validité du jeton (-5 secondes, + 15 minutes)
exp=$(( ${now} + 900 ))
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
for check_module in ${JMB_MODULE_CHECK_MODERATOR} ; do
	if [ -f ${JMB_PATH}/modules/${check_module} ] ; then
		source ${JMB_PATH}/modules/${check_module}
	fi
done

log "token.cgi: meeting_name='${room}', meeting_hash='', email='${auth_mail}', auth_uid='${auth_uid}': ALLOWED"

# Récupérer les infos de la réunion
r=$(sqlite3 -list ${JMB_DB} "\
 SELECT meetings.meeting_id,attendees.attendee_count FROM meetings
 INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
 WHERE meetings.meeting_name='${room}' AND attendees.attendee_email='${auth_mail}' AND attendees.attendee_role='owner' AND meetings.meeting_end > '${now}';")
old_ifs="${IFS}" ; IFS="|"
r=(${r}) ; IFS="${old_ifs}"
meeting_id=${r[0]}
count=${r[1]}

# Incrémentation et MAJ du compteur de connexion
count=${count:-0}
((count++))
echo "UPDATE attendees SET attendee_count='${count}' WHERE attendee_meeting_id='${meeting_id}' AND attendee_email='${auth_mail}' AND attendee_role='owner';" |sqlite3 ${JMB_DB}

# Auth OK + modules de vérification OK
# -> redirection vers la salle de réunion avec le token JWT en paramètre
http_302 "/${room}?jwt=${header_payload}.${signature}"
