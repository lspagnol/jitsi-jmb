
cat<<EOT
Bonjour,

Vous participez à une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: ${conf_duration} minutes
Adresse...: ${JMB_SCHEME}://${SERVER_NAME}/${conf_name}
EOT

source ${JMB_PATH}/inc/mail_footer.sh
source ${JMB_PATH}/inc/mail_footer_guest.sh
