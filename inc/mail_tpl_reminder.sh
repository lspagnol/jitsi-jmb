########################################################################
# Template notification mail: rappel
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Vous participez à une visioconférence:

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/join.cgi?id=${hash}
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Vous modérez/animez une visioconférence:

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/join.cgi?id=${hash}
Modérateurs...: ${moderators:-aucun}
Invités.......: ${guests:-aucun}
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
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${name}
Modérateurs...: ${moderators:-aucun}
Invités.......: ${guests:-aucun}
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_tpl_best_practices.sh
source ${JMB_PATH}/inc/mail_tpl_footer.sh
