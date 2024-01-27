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
# Résultat: variable "is_allowed=0" -> non, "is_allowed=1" -> oui
set_is_allowed

# Flux iCal
if [ -f ${JMB_ICAL_DATA}/by-user/${auth_uid} ] ; then
	ical_hash=$(<${JMB_ICAL_DATA}/by-user/${auth_uid})
else
	ical_hash=$(pwgen 16 1)
	echo "${ical_hash}" > ${JMB_ICAL_DATA}/by-user/${auth_uid}
	echo "${auth_uid}" > ${JMB_ICAL_DATA}/by-hash/${ical_hash}
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

if [ -f ${JMB_DATA}/private_rooms ] && [ "${is_allowed}" = "1" ] ; then

	self=$(grep "^${auth_uid} " ${JMB_DATA}/private_rooms |awk '{print $2}')
	cat<<EOT
<A><I>Ma r&eacute;union priv&eacute;e, disponible &agrave; tout moment: </I></A><BR>
<A href=${self}>${JMB_SCHEME}://${JMB_SERVER_NAME}/${self}</A>
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

for f in $(ls -1 ${JMB_BOOKING_DATA}/ 2>/dev/null |sort -nr) ; do

	unset name owner begin duration end object guests moderators
	unset form_object form_date form_time form_duration form_owner form_action
	unset is_owner is_guest is_moderator
	unset onair

	source ${JMB_BOOKING_DATA}/${f}

	if [ ${now} -le ${end} ] ; then

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
			# Mise en évidence anticipée réunions pour les invités
			if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_GUEST} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
				onair=" bgcolor=\"PaleGreen\""
				form_action="<A href=${name}>Rejoindre</A>"
			fi
		fi

		echo " ${moderators} " |grep -q " ${auth_mail} "
		if [ ${?} -eq 0 ] ; then
			is_moderator=1
			# Mise en évidence anticipée réunions pour les modérateurs
			if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
				onair=" bgcolor=\"PaleGreen\""
				form_action="<A href=/token.cgi?room=${name}>Rejoindre</A>"
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

			if [ "${is_allowed}" = "1" ] && [ "${is_owner}" = "1" ] && [ ${now} -lt ${begin} ] ; then
				form_action="${form_action}<A> </A><A href=/booking.cgi?edit&id=${f}>Editer</A>"
			fi

			# Si l'heure est dépassé -> orange
			if [ ${now} -ge ${begin} ] ; then
				onair=" bgcolor=\"orange\""
			fi

			out_table

		fi

	fi

done

cat<<EOT
  </TABLE>
  <P></P>
EOT

cat<<EOT
  <A><I>Mon flux iCal (synchronisation d'agenda): </I></A><BR>
  <A href=/ical.cgi?${ical_hash}>${JMB_SCHEME}://${JMB_SERVER_NAME}/ical.cgi?${ical_hash}</A>
  <P></P>
EOT

cat<<EOT
  <FORM method="POST">
EOT

if [ "${is_allowed}" = "1" ] ; then
cat<<EOT
    <INPUT type="submit" value="Nouvelle R&eacute;union" onclick="javascript: form.action='?new';"> 
    <P></P>
EOT
fi

cat<<EOT
    <INPUT type="submit" value="Rafraichir la liste" onclick="javascript: form.action='?list';"> 
  </FORM>
  <BR>
  <BR>
  <A>
  <I><B>Rendez-Vous</B> est une solution de visioconf&eacute;rence <B>souveraine</B>,<BR>
  100% Open Source, s&eacute;curis&eacute;e, h&eacute;berg&eacute;e sur nos serveurs.<BR>
  </I><BR>
  </A>
  <A style="color:#FF0000";>
  Pour un fonctionnement optimal, nous recommandons<BR>
  l'utilisation d'un micro-casque.
  </A>
</CENTER>
EOT
