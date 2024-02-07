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

# Décodage et extraction des données GET ("id=" passé dans l'URL)
getdecode

########################################################################

# Récupérer les infos de la réunion
r=$(sqlite3 -list ${JMB_DB} "\
 SELECT meetings.meeting_id,meetings.meeting_name,attendees.attendee_role,attendees.attendee_email,attendees.attendee_count FROM meetings
 INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
 WHERE attendee_meeting_hash='${id}' AND meetings.meeting_end > '${now}';")

old_ifs="${IFS}" ; IFS="|"
r=(${r}) ; IFS="${old_ifs}"
meeting_id=${r[0]}
room=${r[1]}
role=${r[2]}
email=${r[3]}
count=${r[4]}

if [ -z "${room}" ] ; then
	http_403 "La réunion '${room}' n'est pas/plus disponible"
fi

log "join.cgi: meeting_name='${room}', meeting_hash='${id}', email='${email}', role='${role}', auth_uid=''"

# Incrémentation et MAJ du compteur de connexion
count=${count:-0}
((count++))
echo "UPDATE attendees SET attendee_count='${count}' WHERE attendee_meeting_hash='${id}';" |sqlite3 ${JMB_DB}

case ${role} in

	guest)

		# Invité -> redirection vers la salle
		http_302 "/${room}"

	;;

	owner)

		# Propriétaire -> redirection vers le CGI d'authentification
		http_302 "/token.cgi?room=${room}"

	;;

	moderator)

		echo "${email}" | grep -q "${JMB_MAIL_DOMAIN//./\\.}$"
		if [ $? -eq 0 ] ; then

			# L'utilisateur peut s'authentifier
			http_302 "/token.cgi?room=${room}"

		else

			# Utilisateur "externe" (il ne peut pas s'authentifier)

			# On forge une identité pour le jeton à partir de l'adresse mail / DB
			# L'identité sera récupérée dans Jitsi
			auth_uid="unauthenticated"
			auth_mail=${email}
			auth_name=${email%%\@*}
			auth_name=${auth_name//\./ }
			auth_name=${auth_name^^}

			# Création du JWT

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

			# -> redirection vers la salle de réunion avec le token JWT en paramètre
			http_302 "/${room}?jwt=${header_payload}.${signature}"

		fi

	;;

esac
