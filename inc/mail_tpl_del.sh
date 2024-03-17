########################################################################
# Templates notification mail: suppression d'une réunion
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Une visioconférence a été supprimée
Cette notification annule et remplace la précédente.

Organisateur..: ${auth_name} / ${auth_mail}
Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Une visioconférence a été supprimée
Cette notification annule et remplace la précédente.

Organisateur..: ${auth_name} / ${auth_mail}
Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
EOT
	;;

########################################################################

	owner)
cat<<EOT
Bonjour,

Vous avez supprimé une visioconférence.
Cette notification annule et remplace la précédente.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_tpl_footer.sh
