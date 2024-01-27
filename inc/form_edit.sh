########################################################################
# Formulaire d'édition d'une réunion
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
  <H2>Modification de la r&eacute;union</H2>
  <P>${JMB_SCHEME}://${JMB_SERVER_NAME}/${conf_name}</P>
</CENTER>
<FORM method="POST">
  <INPUT type="hidden" name="conf_tsn" value="${tsn}">
  <INPUT type="hidden" name="conf_name" value="${conf_name}">
  <INPUT type="hidden" name="old_conf_date" value="${old_conf_date}">
  <INPUT type="hidden" name="old_conf_time" value="${old_conf_time}">
  <INPUT type="hidden" name="old_conf_moderators" value="${old_conf_moderators}">
  <INPUT type="hidden" name="old_conf_guests" value="${old_conf_guests}">
  <DIV>
    <LABEL>Date</LABEL>
    <INPUT type="date" name="conf_date" min="${conf_min_date}" value="${conf_date}">
  </DIV>
  <DIV>
    <LABEL>Heure</LABEL>
    <INPUT type="time" name="conf_time" step="900" value="${conf_time}">
  </DIV>
  <DIV>
    <LABEL>Dur&eacute;e</LABEL>
    <INPUT type="number" name="conf_duration" min="${JMB_MIN_MEETING_DURATION}" max="${JMB_MAX_MEETING_DURATION}" step="${JMB_STEP_MEETING_DURATION}" value="${conf_duration}">
  </DIV>
  <DIV>
    <LABEL>Objet</LABEL>
    <INPUT type="text" name="conf_object" value="${conf_object}">
  </DIV>
  <DIV>
    <LABEL>Mod&eacute;rateurs <I>max:${JMB_MAX_MODERATORS}</I></LABEL>
    <TEXTAREA id="moderators" name="conf_moderators">${conf_moderators}</TEXTAREA>
  </DIV>
  <DIV>
    <LABEL>Invit&eacute;s <I>max:${JMB_MAX_GUESTS}</I></LABEL>
    <TEXTAREA id="guests" name="conf_guests">${conf_guests}</TEXTAREA>
  </DIV>
  <DIV class="button">
    <INPUT type="submit" value="Modifier la r&eacute;union" onclick="javascript: form.action='?register_edit';">
    <P></P>
    <INPUT type="submit" value="Supprimer la r&eacute;union" onclick="javascript: form.action='?del';"> 
    <P></P>
    <INPUT type="submit" value="Retourner &agrave; la liste" onclick="javascript: form.action='?list';"> 
  </DIV>
</FORM>
<P>
EOT
