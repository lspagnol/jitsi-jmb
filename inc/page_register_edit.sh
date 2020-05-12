########################################################################
# Page de notification: réunion modifiée
########################################################################

cat<<EOT
<HTML>
  <HEAD>
    <TITLE>${JMB_NAME}</TITLE>
    <META http-equiv="refresh" content="${JMB_SLEEP_REDIRECT};url=${url_redirect}">
  </HEAD>
  <BODY>
    <DIV><STRONG>R&eacute;union modifi&eacute;e !</STRONG></DIV>
    <P>Vos invit&eacute;s: ${conf_guests:-aucun}</P>
    <P>Vous allez &ecirc;tre redirig&eacute; dans ${JMB_SLEEP_REDIRECT} secondes.</P>
  </BODY>
</HTML>
EOT
