########################################################################
# Formulaire de la liste des réunions + archives réunions
########################################################################

function meeting_list {
# Liste des réunions -> requête dans variable "req_list"

for f in $(sqlite3 ${JMB_DB} "${req_list}") ; do

	# RAZ des variables utilisées dans le tableau
	unset form_object form_date form_time form_duration form_owner form_action
	unset is_owner is_guest is_moderator
	unset onair hash partstat

	# Récupérer les infos de la réunion
	get_meeting_infos ${f}

	# Récupérer les infos de la table "participants" -> variable "r"
	r=$(sqlite3 ${JMB_DB} "\
		SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${f}';
		SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${f}' AND attendee_partstat='0';
		SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${f}' AND attendee_partstat='1';
		SELECT count() attendee_partstat FROM attendees WHERE attendee_meeting_id='${f}' AND attendee_partstat='2';"
	)

	# On transforme la variable "r" en tableau
	# ${r[0]} -> total
	# ${r[1]} -> pas de réponse
	# ${r[2]} -> acceptés
	# ${r[3]} -> déclinés
	# ${r[4]} -> partstat utilisateur
	r=(${r})

	# Couleur du fond par défaut -> réunion planifiée pas encore disponible
	onair=" bgcolor=\"LightBlue\""

	if [ "${owner}" = "${auth_mail}" ] ; then
		# Proprio
		is_owner=1
		hash=$(get_meeting_hash ${f} ${auth_mail} owner)
		# L'invitation est implicitement acceptée pour le proprio
		partstat="-"
		# Mise en évidence anticipée de la réunion pour le proprio
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			# La réunion n'est plus modifiable
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/token.cgi?room=${name}>Rejoindre</A>"
		fi
	fi

	echo " ${guests} " |grep -q " ${auth_mail} "
	if [ ${?} -eq 0 ] ; then
		# Invité
		is_guest=1
		hash=$(get_meeting_hash ${f} ${auth_mail} guest)
		p=$(sqlite3 ${JMB_DB} "SELECT attendee_partstat FROM attendees WHERE attendee_meeting_hash='${hash}';")
		case ${p} in
			0)
				partstat="Sans r&eacute;ponse"
			;;
			1)
				partstat="Accept&eacute;e"
			;;
			2)
				partstat="D&eacute;clin&eacute;e"
			;;
		esac
		# Mise en évidence anticipée de la réunion pour les invités
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_GUEST} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/join.cgi?id=${hash}>Rejoindre</A>"
		else
			# L'invité peut modifier le status de son invitation
			case ${p} in
				0)
					form_action="<A href=/invitation.cgi?accept&id=${hash}>Accepter</A> / <A href=/invitation.cgi?decline&id=${hash}>D&eacute;cliner</A>"
				;;
				1)
					form_action="<A href=/invitation.cgi?decline&id=${hash}>D&eacute;cliner</A>"
				;;
				2)
					form_action="<A href=/invitation.cgi?accept&id=${hash}>Accepter</A>"
				;;
			esac
		fi
	fi

	echo " ${moderators} " |grep -q " ${auth_mail} "
	if [ ${?} -eq 0 ] ; then
		# Modérateur
		is_moderator=1
		hash=$(get_meeting_hash ${f} ${auth_mail} moderator)
		p=$(sqlite3 ${JMB_DB} "SELECT attendee_partstat FROM attendees WHERE attendee_meeting_hash='${hash}';")
		case ${p} in
			0)
				partstat="Sans r&eacute;ponse"
			;;
			1)
				partstat="Accept&eacute;e"
			;;
			2)
				partstat="D&eacute;clin&eacute;e"
			;;
		esac
		# Mise en évidence anticipée réunions pour les modérateurs
		if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
			onair=" bgcolor=\"PaleGreen\""
			form_action="<A href=/join.cgi?id=${hash}>Rejoindre</A>"
		else
			# Le modérateur peut modifier le status de son invitation
			case ${p} in
				0)
					form_action="<A href=/invitation.cgi?accept&id=${hash}>Accepter</A> / <A href=/invitation.cgi?decline&id=${hash}>D&eacute;cliner</A>"
				;;
				1)
					form_action="<A href=/invitation.cgi?decline&id=${hash}>D&eacute;cliner</A>"
				;;
				2)
					form_action="<A href=/invitation.cgi?accept&id=${hash}>Accepter</A>"
				;;
			esac
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

		# L'heure de début est dépassé
		if [ ${now} -ge ${begin} ] ; then
			onair=" bgcolor=\"Green\""
		fi

	fi

	if [ ${now} -gt ${end} ] ; then
		# C'est une réunion "archivée"
		onair=" bgcolor=\"LightSalmon\""
		form_action="<CENTER>-</CENTER>"
	fi

	cat<<EOT
    <TR${onair}>
      <TD>${form_object}</TD>
      <TD>${form_owner}</TD>
      <TD><CENTER>${form_date}</CENTER></TD>
      <TD><CENTER>${form_time}</CENTER></TD>
      <TD><CENTER>${form_duration}</CENTER></TD>
      <TD><CENTER>
        <DIV title="Invitations accept&eacute;es: ${r[2]}, d&eacute;clin&eacute;es: ${r[3]}, sans r&eacute;ponse: ${r[1]}">
EOT

	if [ "${is_owner}" = "1" ] ; then
		cat<<EOT
          <A href=/booking.cgi?attendees&id=${f}>${r[2]}/${r[0]}</A>
EOT
	else
		cat<<EOT
          ${r[2]}/${r[0]}
EOT
	fi

	cat<<EOT
        </DIV>
      </CENTER></TD>
      <TD><CENTER>${partstat}</CENTER></TD>
      <TD><CENTER>${form_action}</CENTER></TD>
    </TR>
EOT

done

}

########################################################################

# Récupérer le hash iCal de l'utilisateur
ical_hash=$(get_ical_hash ${auth_uid})

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

# Salle de conférence privée
if [ "${is_editor}" = "1" ] ; then
	cat<<EOT
<DIV title="Cliquez sur ce lien pour ouvrir votre salle de r&eacute;union priv&eacute;e">
 <I><A href=/token.cgi?room=${auth_uid}>Ma r&eacute;union priv&eacute;e</A>, disponible &agrave; tout moment:</I>
</DIV>
<DIV title="Donnez ce lien &agrave; votre/vos correspondant(s)">
 <A href=/${auth_uid}>https://${JMB_SERVER_NAME}/${auth_uid}</A>
</DIV>
<P></P>
EOT
fi

# Entête du tableau
cat<<EOT
  <TABLE>
    <STYLE>
      table, th, td {
      padding: 10px;
      border: 2px solid white;
      border-collapse: collapse;
      }
    </STYLE>
    <TR bgcolor="DarkGray">
      <TD><B>Objet</B></TD>
      <TD><B>Organisateur</B></TD>
      <TD><B><CENTER>Date</CENTER></B></TD>
      <TD><B><CENTER>Heure</CENTER></B></TD>
      <TD><B><CENTER>Dur&eacute;e</CENTER></B></TD>
      <TD><B><CENTER>Participants</CENTER></B></TD>
      <TD><B><CENTER>Invitation</CENTER></B></TD>
      <TD><B><CENTER>Action</CENTER></B></TD>
    </TR>
EOT

# Liste des réunions en attente
req_list="
SELECT DISTINCT meetings.meeting_id FROM meetings
INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
WHERE attendees.attendee_email='${auth_mail}' AND meetings.meeting_end > '${now}' ORDER BY meetings.meeting_begin ASC;
"
meeting_list

# Liste des réunions terminées
if [ ! -z "${JMB_SHOW_ARCHIVES}" ] ; then
	ret=$(( ${JMB_SHOW_ARCHIVES} * 3600 * 24 ))
	req_list="
SELECT DISTINCT meetings.meeting_id FROM meetings
INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
WHERE attendees.attendee_email='${auth_mail}' AND meetings.meeting_end < '${now}' AND meetings.meeting_end > '$(( ${now} - ${ret} ))' ORDER BY meetings.meeting_begin DESC;
"
	if [ "${f}" != "" ] ; then
		# Le résultat de la requête précédente (liste des réunions en attente)
		# n'était pas vide -> on ajoute un bloc de séparation
		cat<<EOT
    <TR>
      <TD></TD>
      <TD></TD>
      <TD></TD>
      <TD></TD>
      <TD></TD>
      <TD></TD>
      <TD></TD>
      <TD></TD>
    </TR>
EOT
	fi
	meeting_list
fi

# Fin du tableau
cat<<EOT
  </TABLE>
  <P></P>
  <DIV title="Ce lien permet de synchroniser vos agendas (Thunderbird, smartphones, Nextcloud, ... )">
    <A><I>Mon flux iCal: </I></A><BR>
    <A href=/ical.cgi?${ical_hash}>https://${JMB_SERVER_NAME}/ical.cgi?${ical_hash}</A>
  </DIV>
  <P></P>
  <FORM method="POST">
EOT

if [ "${is_editor}" = "1" ] ; then
	cat<<EOT
    <INPUT type="submit" value="Nouvelle r&eacute;union" onclick="javascript: form.action='?new';"> 
    <P></P>
EOT
fi

cat<<EOT
    <INPUT type="submit" value="Rafraichir la page" onclick="javascript: form.action='?list';"> 
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
