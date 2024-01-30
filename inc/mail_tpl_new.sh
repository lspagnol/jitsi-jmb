########################################################################
# Template notification mail: création d'une réunion
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Je vous invite à une visioconférence.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/${conf_name}

Merci de confirmer votre présence.
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Je vous invite à animer une visioconférence.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${conf_name}
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}
EOT
	;;

########################################################################

	owner)
cat<<EOT
Bonjour,

Vous avez réservé une visioconférence.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${conf_name}
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_best_practices.sh
source ${JMB_PATH}/inc/mail_footer.sh
