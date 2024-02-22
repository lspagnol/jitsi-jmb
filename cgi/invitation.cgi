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

case ${query} in
	accept)
		partstat=1
		resp="pr&eacute;sence"
	;;
	decline)
		partstat=2
		resp="absence"
	;;
esac

# MAJ du status de l'invitation
sqlite3 ${JMB_DB} "UPDATE attendees SET attendee_partstat='${partstat}' WHERE attendee_meeting_hash='${id}';"

# On verifie le cookie
set |egrep '^HTTP_COOKIE=' |grep -q 'viajmb=1'
if [ ${?} -eq 0 ] ; then

	# Le cookie "viajmb=1" est présent, redirection sur le CGI de l'interface de gestion
	http_302 "${JMB_DEFAULT_URL_REDIRECT}"

else

	cat<<EOT>${out}
<HTML>
  <HEAD>
    <TITLE>${JMB_NAME}</TITLE>
  </HEAD>
  <BODY>
    <DIV><STRONG>L'organisateur de la r&eacute;union sera inform&eacute; de votre ${resp}.</STRONG></DIV>
    <P>Vous pouvez fermer cet onglet.</P>
  </BODY>
</HTML>
EOT

	http_200

fi
