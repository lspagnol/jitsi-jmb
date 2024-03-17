########################################################################
# Modification réunion / SQLite
########################################################################

# Sélection du template "modification d'une réunion"
mail_tpl="${JMB_PATH}/inc/mail_tpl_edit.sh"

# Table "meetings"
cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
UPDATE meetings SET
 meeting_object='${object}',
 meeting_begin='${begin}',
 meeting_duration='${duration}',
 meeting_end='${end}'
WHERE meeting_id='${tsn}';
EOT

# Table attendees (guest)
echo -e "${conf_guests// /\\n}" |sort > ${JMB_CGI_TMP}/${tsn}_guests.new
echo -e "${old_conf_guests// /\\n}" |sort > ${JMB_CGI_TMP}/${tsn}_guests.old
diff ${JMB_CGI_TMP}/${tsn}_guests.old ${JMB_CGI_TMP}/${tsn}_guests.new |egrep '^(<|>) ' |while read L ; do

	L=(${L})

	case ${L[0]} in
		">")
			# Ajout / DB
			hash=$(gen_meeting_hash)
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','${hash}','guest','${L[1]}');
EOT
		;;

		"<")
			# Suppression / DB
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
DELETE FROM attendees
WHERE attendee_meeting_id='${tsn}' AND attendee_role='guest' AND attendee_email='${L[1]}';
EOT
			# Mail de notification
			role=guest
			subject="$(utf8_to_mime ${JMB_SUBJECT_DEL_GUEST})"
			source ${mail_tpl} |mail\
			 -r "${JMB_MAIL_FROM_NOTIFICATION}"\
			 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			 -a "Content-Transfer-Encoding: 8bit"\
			 -a "Content-Language: fr"\
			 -a "From: ${JMB_NAME} <${JMB_MAIL_FROM_NOTIFICATION}>"\
			 -a "subject: ${subject}"\
			 ${L[1]}
		;;

	esac

done

[ -f ${JMB_CGI_TMP}/${tsn}_guests.old ] && rm ${JMB_CGI_TMP}/${tsn}_guests.old
[ -f ${JMB_CGI_TMP}/${tsn}_guests.new ] && rm ${JMB_CGI_TMP}/${tsn}_guests.new

# Table attendees (moderator)
echo -e "${conf_moderators// /\\n}" |sort > ${JMB_CGI_TMP}/${tsn}_moderators.new
echo -e "${old_conf_moderators// /\\n}" |sort > ${JMB_CGI_TMP}/${tsn}_moderators.old
diff ${JMB_CGI_TMP}/${tsn}_moderators.old ${JMB_CGI_TMP}/${tsn}_moderators.new |egrep '^(<|>) ' |while read L ; do

	L=(${L})

	case ${L[0]} in

		">")
			# Ajout / DB
			hash=$(gen_meeting_hash)
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','${hash}','moderator','${L[1]}');
EOT
		;;

		"<")
			# Suppression /DB
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
DELETE FROM attendees
WHERE attendee_meeting_id='${tsn}' AND attendee_role='moderator' AND attendee_email='${L[1]}';
EOT
			# Mail de notification
			role=guest
			subject="$(utf8_to_mime ${JMB_SUBJECT_DEL_GUEST})"
			source ${mail_tpl} |mail\
			 -r "${JMB_MAIL_FROM_NOTIFICATION}"\
			 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			 -a "Content-Transfer-Encoding: 8bit"\
			 -a "Content-Language: fr"\
			 -a "From: ${JMB_NAME} <${JMB_MAIL_FROM_NOTIFICATION}>"\
			 -a "subject: ${subject}"\
			 ${L[1]}
		;;

	esac

done
[ -f ${JMB_CGI_TMP}/${tsn}_moderators.old ] && rm ${JMB_CGI_TMP}/${tsn}_moderators.old
[ -f ${JMB_CGI_TMP}/${tsn}_moderators.new ] && rm ${JMB_CGI_TMP}/${tsn}_moderators.new

# Enregistrement des données
cat ${JMB_CGI_TMP}/${tsn}.sql |sqlite3 ${JMB_DB}
rm ${JMB_CGI_TMP}/${tsn}.sql

log "booking.cgi: edit: meeting_name='${conf_name}', meeting_id='${tsn}', auth_uid='${auth_uid}'"
