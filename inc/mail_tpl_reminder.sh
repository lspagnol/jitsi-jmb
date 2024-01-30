########################################################################
# Template notification mail: rappel
########################################################################

case ${role} in

########################################################################

	guest)
cat<<EOT
Bonjour,

Vous participez à une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: $(( ${duration} / 60 )) minutes
Adresse...: ${JMB_SCHEME}://${JMB_SERVER_NAME}/${name}
EOT
	;;

########################################################################

	moderator)
cat<<EOT
Bonjour,

Vous animez une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: $(( ${duration} / 60 )) minutes
Adresse...: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${name}
EOT
	;;

########################################################################

	owner)
cat<<EOT
Bonjour,

Vous organisez une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: $(( ${duration} / 60 )) minutes
Adresse...: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${name}
EOT
	;;

########################################################################

esac

source ${JMB_PATH}/inc/mail_tpl_best_practices.sh
source ${JMB_PATH}/inc/mail_tpl_footer.sh
