#!/bin/bash

########################################################################
# CGI de gestion des invitations
########################################################################

# Timestamps
now=$(date +%s)
tsn=$(date +%s%N)

########################################################################

# Charger la configuration et les fonctions
JMB_PATH=/opt/jitsi-jmb
source ${JMB_PATH}/etc/jmb.cf
source ${JMB_PATH}/lib/jmb.lib

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

# Décodage et extraction des données GET ("id=" passé dans l'URL) -> $id
# action (accept ou decline) -> $query
getdecode

########################################################################
set>${JMB_DEBUG}
case ${query} in
	accept)
		partstat=1
	;;
	decline)
		partstat=2
	;;
esac

sqlite3 ${JMB_DB} "UPDATE attendees SET attendee_partstat='${partstat}' WHERE attendee_meeting_hash='${id}';"

cat<<EOT>${out}
<HTML>
  <HEAD>
    <TITLE>${JMB_NAME}</TITLE>
  </HEAD>
  <BODY>
    <DIV><STRONG>L'organisateur de la r&eacute;union sera notifi&eacute; de votre r&eacute;ponse.</STRONG></DIV>
    <P>Vous pouvez fermer cet onglet.</P>
  </BODY>
</HTML>
EOT

http_200
