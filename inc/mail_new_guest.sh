########################################################################
# Template notification mail: création d'une réunion -> invités
########################################################################

cat<<EOT
Bonjour,

Je vous invite à une visioconférence.

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: ${conf_duration} minutes
Adresse...: ${JMB_SCHEME}://${JMB_SERVER_NAME}/${conf_name}

Merci de confirmer votre présence.
EOT

source ${JMB_PATH}/inc/mail_best_practices.sh
source ${JMB_PATH}/inc/mail_footer_guest.sh
