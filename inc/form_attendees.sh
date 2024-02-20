########################################################################
# Formulaire de la liste des participants
########################################################################

function out_table {

# Récupérer les infos de la table "participants"
r=$(sqlite3 ${JMB_DB} "\
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='0';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='1';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='2'"
)

# On transforme le résulat en tableau
# ${r[0]} -> total
# ${r[1]} -> pas de réponse
# ${r[2]} -> acceptés
# ${r[3]} -> déclinés
r=(${r})

cat<<EOT
    <TR>
      <TD${onair}>${form_object}</TD>
      <TD${onair}>${form_owner}</TD>
      <TD${onair}><CENTER>
        <DIV title="Invitations accept&eacute;es: ${r[2]}, d&eacute;clin&eacute;es: ${r[3]}, sans r&eacute;ponse: ${r[1]}, ">
          <A>${r[2]}/${r[0]}</A>
        </DIV>
      </CENTER></TD>
      <TD${onair}><CENTER>${form_date}</CENTER></TD>
      <TD${onair}><CENTER>${form_time}</CENTER></TD>
      <TD${onair}><CENTER>${form_duration}</CENTER></TD>
      <TD${onair}>${form_action}</TD>
    </TR>
EOT
}

########################################################################

[ ! -z "${object}" ] && form_object=$(utf8_to_html "${object}")
[ ! -z "${duration}" ] && form_duration=$(( ${duration} / 60 ))
[ ! -z "${owner}" ] && form_owner=${owner}
if [ ! -z "${begin}" ] ; then
	form_date=$(date -d@${begin} "+%d/%m/%Y")
	form_time=$(date -d@${begin} "+%H:%M")
fi

# Mise en évidence anticipée réunions pour le proprio
if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
	onair=" bgcolor=\"PaleGreen\""
	form_action="<A href=/token.cgi?room=${name}>Rejoindre</A>"
fi

# Si l'heure est dépassé -> orange
if [ ${now} -ge ${begin} ] ; then
	onair=" bgcolor=\"orange\""
else
	form_action="${form_action}<A> </A><A href=/booking.cgi?edit&id=${id}>Editer</A>"
fi

# Récupérer les infos de la table "participants"
r=$(sqlite3 ${JMB_DB} "\
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='0';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='1';
	SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${id}' AND attendee_partstat='2'"
)

# On transforme le résulat en tableau
# ${r[0]} -> total
# ${r[1]} -> pas de réponse
# ${r[2]} -> acceptés
# ${r[3]} -> déclinés
r=(${r})

# 1er tableau: résumé de la réunion

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
  <H2>Suivi des participants</H2>
  <P></P>
  <TABLE>
    <STYLE>
      table, th, td {
      padding: 10px;
      border: 2px solid black;
      border-collapse: collapse;
      }
    </STYLE>
    <TR bgcolor="LightGray">
      <TD><B>Objet</B></TD>
      <TD><B>Organisateur</B></TD>
      <TD><B>Participants</B></TD>
      <TD><B><CENTER>Date</CENTER></B></TD>
      <TD><B><CENTER>Heure</CENTER></B></TD>
      <TD><B><CENTER>Dur&eacute;e</CENTER></B></TD>
      <TD><B>Action</B></TD>
    </TR>
    <TR${onair}>
      <TD>${form_object}</TD>
      <TD>${form_owner}</TD>
      <TD><CENTER>
        <DIV title="Invitations accept&eacute;es: ${r[2]}, d&eacute;clin&eacute;es: ${r[3]}, sans r&eacute;ponse: ${r[1]}, ">
          <A>${r[2]}/${r[0]}</A>
        </DIV>
      </CENTER></TD>
      <TD><CENTER>${form_date}</CENTER></TD>
      <TD><CENTER>${form_time}</CENTER></TD>
      <TD><CENTER>${form_duration}</CENTER></TD>
      <TD>${form_action}</TD>
    </TR>
   </TABLE>
  <P></P>
  <TABLE>
    <TR bgcolor="LightGray">
      <TD><B>Participant</B></TD>
      <TD><B>R&ocirc;le</B></TD>
      <TD><B>Invitation</B></TD>
      <TD><B><CENTER>Cnxs</CENTER></B></TD>
    </TR>
EOT

# Tableau "liste des participants"
sqlite3 -list ${JMB_DB} "\
 SELECT attendee_email,attendee_role,attendee_partstat,attendee_count FROM attendees
 WHERE attendee_meeting_id='${id}' AND attendee_role != 'owner';" |while read r ; do

# On transforme le résulat en tableau
old_ifs="${IFS}"
IFS="|"
r=(${r})
IFS="${old_ifs}"

mail=${r[0]}

case ${r[1]} in
	owner)
		role="Propri&eacute;taire"
	;;
	moderator)
		role="Mod&eacute;rateur"
	;;
	guest)
		role="Invit&eacute;"
	;;
	*)
		role="Inconnu"
	;;
esac

case ${r[2]} in
	0)
		partstat="Sans r&eacute;ponse"
		bgcolor=""
	;;
	1)
		partstat="Accept&eacute;e"
		bgcolor=" bgcolor=\"PaleGreen\""
	;;
	2)
		partstat="D&eacute;clin&eacute;e"
		bgcolor=" bgcolor=\"Red\""
	;;
	*)
		partstat="Inconnu"
		bgcolor=""
	;;
esac

cnxs=${r[3]}

cat<<EOT
    <TR${bgcolor}>
      <TD>${mail}</TD>
      <TD>${role}</TD>
      <TD>${partstat}</TD>
      <TD><CENTER>${cnxs}</CENTER></TD>
     </TR>
EOT

done

cat<<EOT
  </TABLE>
  <P></P>
  <FORM method="POST">
EOT

cat<<EOT
    <INPUT type="submit" value="Rafraichir la page" onclick="javascript: form.action='?attendees&id=${id}';">
    <P></P>
    <INPUT type="submit" value="Retourner &agrave; la liste" onclick="javascript: form.action='?list';"> 
  </FORM>
  <BR>
  <BR>
  <A>
  <I><B>${JMB_NAME}</B> est une solution de visioconf&eacute;rence <B>souveraine</B>,<BR>
  100% Open Source, s&eacute;curis&eacute;e, h&eacute;berg&eacute;e sur nos serveurs.<BR>
  </I><BR>
  </A>
  <A style="color:#FF0000";>
  Pour un fonctionnement optimal, nous recommandons<BR>
  l'utilisation d'un micro-casque.
  </A>
</CENTER>
EOT
