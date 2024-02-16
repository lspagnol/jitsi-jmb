########################################################################
# Template notification mail: édition d'une réunion
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Je vous invite à une visioconférence.
Cette notification annule et remplace la précédente.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/join.cgi?id=${hash}

Merci d'indiquer votre présence en cliquant sur un des liens suivants:
Accepter l'invitation: ${JMB_SCHEME}://${JMB_SERVER_NAME}/invitation.cgi?accept&id=${hash}
Décliner l'invitation: ${JMB_SCHEME}://${JMB_SERVER_NAME}/invitation.cgi?decline&id=${hash}
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Je vous invite à modérer/animer une visioconférence.
Cette notification annule et remplace la précédente.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/join.cgi?id=${hash}
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}

Merci d'indiquer votre présence en cliquant sur un des liens suivants:
Accepter l'invitation: ${JMB_SCHEME}://${JMB_SERVER_NAME}/invitation.cgi?accept&id=${hash}
Décliner l'invitation: ${JMB_SCHEME}://${JMB_SERVER_NAME}/invitation.cgi?decline&id=${hash}
EOT
	;;

########################################################################

	owner)
cat<<EOT
Bonjour,

Vous avez réservé une visioconférence.
Cette notification annule et remplace la précédente.

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

source ${JMB_PATH}/inc/mail_tpl_best_practices.sh
source ${JMB_PATH}/inc/mail_tpl_footer.sh
