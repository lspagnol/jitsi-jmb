########################################################################
# Formulaire de la liste des réunions
########################################################################

function out_table {
cat<<EOT
    <TR>
      <TD${onair}>${form_object}</TD>
      <TD${onair}>${form_mail_owner}</TD>
      <TD${onair}><CENTER>${form_date}</CENTER></TD>
      <TD${onair}><CENTER>${form_time}</CENTER></TD>
      <TD${onair}><CENTER>${form_duration}</CENTER></TD>
      <TD${onair}>${form_action}</TD>
    </TR>
EOT
}

########################################################################

cat<<EOT
<CENTER>
  <H2>Mes r&eacute;unions</H2>
  <P></P>
EOT

if [ -f ${JMB_DATA}/private_rooms ] ; then

	uid=$($JMB_LDAPSEARCH mail=${HTTP_MAIL} uid |grep "^uid: " |awk '{print $2}')
	self=$(grep "^${uid} " ${JMB_DATA}/private_rooms |awk '{print $2}')
	cat<<EOT
<A><I>Ma r&eacute;union priv&eacute;e, disponible &agrave; tout moment: </I></A><BR>
<A href=${self}>${JMB_SCHEME}://${SERVER_NAME}/${self}</A>
<P></P>
EOT

fi
cat<<EOT
  <TABLE>
    <STYLE>
      table, th, td {
      padding: 10px;
      border: 1px solid black;
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

	unset name mail_owner begin duration end object guests
	unset form_object form_date form_time form_duration form_mail_owner form_action
	unset is_owner is_guest
	unset onair

	source ${JMB_BOOKING_DATA}/${f}

	if [ ${now} -le ${end} ] ; then

		echo " ${guests} " |grep -q " ${HTTP_MAIL} "
		if [ ${?} -eq 0 ] ; then
			is_guest=1
			# Mise en évidence anticipée réunions pour les invités
			if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_GUEST} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
				onair=" bgcolor=\"PaleGreen\""
				form_action="<A href=${name}>Rejoindre</A>"
			fi
		fi

		if [ "${HTTP_MAIL}" = "${mail_owner}" ] ; then
			is_owner=1
			# Mise en évidence anticipée réunions pour le proprio
			if [ $(( ${now} + ${JMB_LIST_HIGHLIGHT_OWNER} )) -ge ${begin} ] && [ ${now} -le ${end} ] ; then
				# La réunion n'est plus modifiable
				onair=" bgcolor=\"PaleGreen\""
				form_action="<A href=${name}>Rejoindre</A>"
			fi
		fi

		if [ "${is_owner}" = "1" ] || [ "${is_guest}" = "1" ] ; then

			[ ! -z "${object}" ] && form_object=$(utf8_to_html "${object}")
			if [ ! -z "${begin}" ] ; then
				form_date=$(date -d@${begin} "+%d/%m/%Y")
				form_time=$(date -d@${begin} "+%H:%M")
			fi
			[ ! -z "${duration}" ] && form_duration=$(( ${duration} / 60 ))
			[ ! -z "${mail_owner}" ] && form_mail_owner=${mail_owner}

			if [ "${is_owner}" = "1" ] && [ -z "${onair}" ] ; then
				form_action="${form_action}<A> </A><A href=/booking.cgi?edit&id=${f}>Editer</A>"
			fi

			out_table

		fi

	fi

done

cat<<EOT
  </TABLE>
  <P></P>
  <FORM method="POST">
    <INPUT type="submit" value="Nouvelle R&eacute;union" onclick="javascript: form.action='?new';"> 
    <P></P>
    <INPUT type="submit" value="Rafraichir la liste" onclick="javascript: form.action='?list';"> 
    <P></P>
    <INPUT type="submit" value="Retourner &agrave; la page d'accueil" onclick="javascript: form.action='/';"> 
  </FORM>
</CENTER>
EOT
