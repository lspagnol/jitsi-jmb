########################################################################
# Template notification mail: rappel -> invités
########################################################################

cat<<EOT
Bonjour,

Vous participez à une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: $(( ${duration} / 60 )) minutes
Adresse...: ${JMB_SCHEME}://${JMB_SERVER_NAME}/${name}
EOT

source ${JMB_PATH}/inc/mail_best_practices.sh
source ${JMB_PATH}/inc/mail_footer_guest.sh
