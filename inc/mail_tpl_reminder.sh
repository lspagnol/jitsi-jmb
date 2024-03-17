########################################################################
# Template notification mail: rappel
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Vous participez à une visioconférence:

Organisateur..: ${owner}
Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${duration} minutes

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/join.cgi?id=${hash}
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Vous modérez/animez une visioconférence:

Organisateur..: ${owner}
Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${duration} minutes
Modérateurs...: ${moderators:-aucun}
Invités.......: ${guests:-aucun}

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/join.cgi?id=${hash}
EOT
	;;

########################################################################

	owner)
cat<<EOT
Bonjour,

Vous organisez une visioconférence:

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${duration} minutes
Modérateurs...: ${moderators:-aucun}
Invités.......: ${guests:-aucun}

* Vous pourrez rejoindre la réunion en cliquant sur le lien suivant:
https://${JMB_SERVER_NAME}/token.cgi?room=${name}
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_tpl_footer.sh
source ${JMB_PATH}/inc/mail_tpl_best_practices.sh
