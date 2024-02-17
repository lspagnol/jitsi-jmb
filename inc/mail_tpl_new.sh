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

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/join.cgi?id=${hash}

* Merci de confirmer votre votre présence ou votre absence en cliquant sur un des liens suivants:
ACCEPTER l'invitation: https://${JMB_SERVER_NAME}/invitation.cgi?accept&id=${hash}
DECLINER l'invitation: https://${JMB_SERVER_NAME}/invitation.cgi?decline&id=${hash}
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Je vous invite à modérer/animer une visioconférence.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/join.cgi?id=${hash}

* Merci de confirmer votre votre présence ou votre absence en cliquant sur un des liens suivants:
ACCEPTER l'invitation: https://${JMB_SERVER_NAME}/invitation.cgi?accept&id=${hash}
DECLINER l'invitation: https://${JMB_SERVER_NAME}/invitation.cgi?decline&id=${hash}
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
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/token.cgi?room=${conf_name}
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_tpl_best_practices.sh
source ${JMB_PATH}/inc/mail_tpl_footer.sh
