
cat<<EOT
Bonjour,

Vous organisez une visioconférence:

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: $(( ${duration} / 60 )) minutes
Adresse...: ${JMB_SCHEME}://${SERVER_NAME}/${name}
EOT

source ${JMB_PATH}/inc/mail_footer.sh
source ${JMB_PATH}/inc/mail_footer_owner.sh
