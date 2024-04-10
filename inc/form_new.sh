########################################################################
# Formulaire de création d'une réunion
########################################################################

cat<<EOT
<CENTER>
EOT

# Afficher le logo si disponible
if [ -f ${JMB_PATH}/etc/logo.png ] ; then
	cat<<EOT
  <IMG src=logo.png>
EOT
fi

cat<<EOT
  <H2>Nouvelle r&eacute;union</H2>
  <P>https://${JMB_SERVER_NAME}/${conf_name}</P>
</CENTER>
<FORM method="POST">
  <INPUT type="hidden" name="conf_tsn" value="${tsn}">
  <INPUT type="hidden" name="conf_name" value="${conf_name}">
  <DIV>
    <LABEL>Date</LABEL>
    <INPUT type="date" name="conf_date" min="${conf_date}" value="${conf_date}">
  </DIV>
  <DIV>
    <LABEL>Heure</LABEL>
    <INPUT type="time" name="conf_time" step="900" value="${conf_time}">
  </DIV>
  <DIV title="Minutes">
    <LABEL>Dur&eacute;e</LABEL>
    <INPUT type="number" name="conf_duration" min="${JMB_MIN_MEETING_DURATION}" max="${JMB_MAX_MEETING_DURATION}" step="${JMB_STEP_MEETING_DURATION}" value="${JMB_DEFAULT_MEETING_DURATION}">
  </DIV>
  <DIV title="Caract&egrave;res alphanum&eacute;riques uniquement">
    <LABEL>Objet</LABEL>
    <INPUT type="text" name="conf_object" value="${JMB_DEFAULT_OBJECT}">
  </DIV>
  <DIV title="Adresse(s) mail, un mod&eacute;rateur peut &ecirc;tre un utilisateur externe, le cr&eacute;ateur est implicitement mod&eacute;rateur">
    <LABEL>Mod&eacute;rateurs <I>max:${JMB_MAX_MODERATORS}</I></LABEL>
    <TEXTAREA id="moderators" name="conf_moderators"></TEXTAREA>
  </DIV>
  <DIV title="Adresse(s) mail, un invit&eacute; peut &ecirc;tre un utilisateur externe">
    <LABEL>Invit&eacute;s <I>max:${JMB_MAX_GUESTS}</I></LABEL>
    <TEXTAREA id="guests" name="conf_guests"></TEXTAREA>
  </DIV>
  <DIV class="button">
    <DIV title="Les participants seront notifi&eacute;s par mail">
      <INPUT type="submit" value="Cr&eacute;er la r&eacute;union" onclick="javascript: form.action='?register_new';">
    </DIV>
    <P></P>
    <INPUT type="submit" value="R&eacute;initialiser le formulaire" onclick="javascript: form.action='?new';"> 
    <P></P>
    <INPUT type="submit" value="Retourner &agrave; la liste" onclick="javascript: form.action='?list';"> 
  </DIV>
</FORM>
<P>
EOT
