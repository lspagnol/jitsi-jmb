########################################################################
# Template notification mail: suppression d'une réunion -> propriétaire
########################################################################

cat<<EOT
Bonjour,

Vous avez supprimé une visioconférence.
Cette notification annule et remplace la précédente.

Objet.........: ${object}
Date..........: $(date -d @${begin} +"%d/%m/%Y")
Heure.........: $(date -d @${begin} +%H:%M)
Durée.........: ${conf_duration} minutes
Adresse.......: ${JMB_SCHEME}://${JMB_SERVER_NAME}/token.cgi?room=${conf_name}
Modérateurs...: ${conf_moderators:-aucun}
Invités.......: ${conf_guests:-aucun}
EOT

source ${JMB_PATH}/inc/mail_footer_owner.sh
