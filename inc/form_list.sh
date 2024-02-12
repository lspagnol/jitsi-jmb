########################################################################
# Formulaire de la liste des réunions
########################################################################

function out_table {
cat<<EOT
    <TR>
      <TD${onair}>${form_object}</TD>
      <TD${onair}>${form_owner}</TD>
      <TD${onair}><CENTER>${form_date}</CENTER></TD>
      <TD${onair}><CENTER>${form_time}</CENTER></TD>
      <TD${onair}><CENTER>${form_duration}</CENTER></TD>
      <TD${onair}>${form_action}</TD>
    </TR>
EOT
}

########################################################################

# Récupérer les infos utilisateur
[ -f ${JMB_PATH}/modules/${JMB_IDENTITY_MODULE}.sh ] && source ${JMB_PATH}/modules/${JMB_IDENTITY_MODULE}.sh

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_editor=0" -> non, "is_editor=1" -> oui
set_is_editor

# Flux iCal
ical_hash=$(sqlite3 ${JMB_DB} "SELECT ical_hash FROM ical WHERE ical_owner='${auth_uid}';")
if [ -z "${ical_hash}" ] ; then
	ical_hash=$(pwgen 16 1)
	echo "INSERT INTO ical (ical_owner,ical_hash) values ('${auth_uid}','${ical_hash}');" |sqlite3 ${JMB_DB}
fi

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
  <H2>Mes r&eacute;unions</H2>
  <P></P>
EOT

if [ -f ${JMB_DATA}/private_rooms ] && [ "${is_editor}" = "1" ] ; then

	self=$(grep "^${auth_uid} " ${JMB_DATA}/private_rooms |awk '{print $2}')
	cat<<EOT
<DIV title="Cliquez sur ce lien pour ouvrir votre salle de r&eacute;union priv&eacute;e">
 <I><A href=token.cgi?room=${self}>Ma r&eacute;union priv&eacute;e</A>, disponible &agrave; tout moment:</I>
</DIV>
<DIV title="Donnez ce lien &agrave; votre/vos correspondant(s)">
 <A href=${self}>${JMB_SCHEME}://${JMB_SERVER_NAME}/${self}</A>
</DIV>
<P></P>
EOT
fi

cat<<EOT
  <TABLE>
    <STYLE>
      table, th, td {
      padding: 10px;
      border: 2px solid black;
      border-collapse: collapse;
      }
    </STYLE>
    <TR>
      <TD bgcolor="LightGray"><B>Objet</B></TD>
      <TD bgcolor="LightGray"><B>Organisateur</B></TD>
      <TD bgcolor="LightGray"><B><CENTER>Date</CENTER></B></TD>
      <TD bgcolor="LightGray"><B><CENTER>Heure</CENTER></B></TD>
      <TD bgcolor="LightGray"><B><CENTER>Dur&eacute;e</CENTER></B></TD>
      <TD bgcolor="LightGray"><B>Action</B></TD>
    </TR>
EOT

# Liste des réunions planifiées
for f in $(\
	sqlite3 ${JMB_DB} "\
		SELECT meetings.meeting_id FROM meetings
		INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
		WHERE attendees.attendee_email='${auth_mail}' AND meetings.meeting_end > '${now}';") ; do

	unset name owner begin duration end object guests moderators
	unset form_object form_date form_time form_duration form_owner form_action
	unset is_owner is_guest is_moderator
	unset onair hash

	# Récupérer les infos de la réunion
	get_meeting_infos ${f}

	if [ "${owner}" = "${auth_mail}" ] ; then
		is_owner=1
		# Mise en évidence anticipée réunions pour le proprio
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			# La réunion n'est plus modifiable
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/token.cgi?room=${name}>Rejoindre</A>"
		fi
	fi

	echo " ${guests} " |grep -q " ${auth_mail} "
	if [ ${?} -eq 0 ] ; then
		is_guest=1
		get_meeting_hash ${f} ${auth_mail} guest
		# Mise en évidence anticipée réunions pour les invités
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_GUEST} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/join.cgi?id=${hash}>Rejoindre</A>"
		fi
	fi

	echo " ${moderators} " |grep -q " ${auth_mail} "
	if [ ${?} -eq 0 ] ; then
		is_moderator=1
		get_meeting_hash ${f} ${auth_mail} moderator
		# Mise en évidence anticipée réunions pour les modérateurs
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/join.cgi?id=${hash}>Rejoindre</A>"
		fi
	fi

	if [ "${is_owner}" = "1" ] || [ "${is_guest}" = "1" ] || [ "${is_moderator}" = "1" ] ; then

		[ ! -z "${object}" ] && form_object=$(utf8_to_html "${object}")
		if [ ! -z "${begin}" ] ; then
			form_date=$(date -d@${begin} "+%d/%m/%Y")
			form_time=$(date -d@${begin} "+%H:%M")
		fi
		[ ! -z "${duration}" ] && form_duration=$(( ${duration} / 60 ))
		[ ! -z "${owner}" ] && form_owner=${owner}

		if [ "${is_editor}" = "1" ] && [ "${is_owner}" = "1" ] && [ ${now} -lt ${begin} ] ; then
			form_action="${form_action}<A> </A><A href=/booking.cgi?edit&id=${f}>Editer</A>"
		fi

		# Si l'heure est dépassé -> orange
		if [ ${now} -ge ${begin} ] ; then
			onair=" bgcolor=\"orange\""
		fi

		out_table

	fi

done

cat<<EOT
  </TABLE>
  <P></P>
EOT

cat<<EOT
  <DIV title="Ce lien permet de synchroniser vos agendas (Thunderbird, smartphones, Nextcloud, ...)">
    <A><I>Mon flux iCal: </I></A><BR>
    <A href=/ical.cgi?${ical_hash}>${JMB_SCHEME}://${JMB_SERVER_NAME}/ical.cgi?${ical_hash}</A>
  </DIV>
    <P></P>
EOT

cat<<EOT
  <FORM method="POST">
EOT

if [ "${is_editor}" = "1" ] ; then
cat<<EOT
    <INPUT type="submit" value="Nouvelle r&eacute;union" onclick="javascript: form.action='?new';"> 
    <P></P>
EOT
fi

cat<<EOT
    <INPUT type="submit" value="Rafraichir la liste" onclick="javascript: form.action='?list';"> 
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
