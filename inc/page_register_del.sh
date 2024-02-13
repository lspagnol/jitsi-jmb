########################################################################
# Page de notification: réunion supprimée
########################################################################

cat<<EOT
<HTML>
  <HEAD>
    <TITLE>${JMB_NAME}</TITLE>
    <META http-equiv="refresh" content="${JMB_SLEEP_REDIRECT};url=/booking.cgi?list">
  </HEAD>
  <BODY>
    <DIV><STRONG>R&eacute;union supprim&eacute;e !</STRONG></DIV>
    <P>Mod&eacute;rateurs: ${conf_moderators:-aucun}</P>
    <P>Invit&eacute;s: ${conf_guests:-aucun}</P>
    <P>Vous allez &ecirc;tre redirig&eacute; dans ${JMB_SLEEP_REDIRECT} secondes.</P>
  </BODY>
</HTML>
EOT
