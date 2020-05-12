########################################################################
# Template notification mail: suppression d'une réunion -> invités
########################################################################

cat<<EOT
Bonjour,

J'ai annulé une visioconférence.
Cette notification annule et remplace la précédente.

Objet.....: ${object}
Date......: $(date -d @${begin} +"%d/%m/%Y")
Heure.....: $(date -d @${begin} +%H:%M)
Durée.....: ${conf_duration} minutes
Adresse...: ${JMB_SCHEME}://${SERVER_NAME}/${conf_name}
EOT
