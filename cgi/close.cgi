#!/bin/bash

########################################################################
# CGI appelé lors de la fin d'une conférence (/static/close2.html)
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

# On vérifie le referer
set |egrep -q "^HTTP_REFERER=${JMB_SCHEME}://${JMB_SERVER_NAME//./\\.}/"
if [ $? -ne 0 ] ; then
	# L'appel au CGI n'est pas fait par la fin d'une session Jitsi
	# -> redirection vers le CGI de l'interface de gestion
	http_302 "/booking.cgi"
fi

# On verifie le cookie
set |egrep '^HTTP_COOKIE=' |egrep -q '(^|;| )viajmb=1'
if [ ${?} -eq 0 ] ; then
	# Le cookie "viajmb=1" est présent, redirection sur le CGI de l'interface de gestion
	url_redirect=${JMB_DEFAULT_URL_REDIRECT}
else
	# Pas de cookie, redirection sur l'URL ${JMB_REDIRECT_CLOSE}
	url_redirect=${JMB_REDIRECT_CLOSE}
fi

cat<<EOT>${out}
<HTML>
  <HEAD>
    <TITLE>${JMB_NAME}</TITLE>
    <META http-equiv="refresh" content="${JMB_SLEEP_REDIRECT};url=${url_redirect}">
  </HEAD>
  <BODY>
    <DIV><STRONG>La r&eacute;union est termin&eacute;e !</STRONG></DIV>
    <P>Vous allez &ecirc;tre redirig&eacute; dans ${JMB_SLEEP_REDIRECT} secondes.</P>
  </BODY>
</HTML>
EOT

http_200
