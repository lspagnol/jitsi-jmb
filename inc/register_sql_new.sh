########################################################################
# Enregistrement nouvelle réunion / SQLite
########################################################################

# Table "meetings"
cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO meetings (meeting_id,meeting_name,meeting_object,meeting_begin,meeting_duration,meeting_end,meeting_create) 
VALUES ('${tsn}','${conf_name}','${object}','${begin}','${duration}','${end}','${now}');
EOT

# Table attendees (owner)
# Le hash est inutile car le propriétaire peut forcément s'authentifier
# -> Accès direct via "token.cgi"
cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email,attendee_partstat)
VALUES ('${tsn}',NULL,'owner','${auth_mail}','1');
EOT

# Table attendees (moderator)
# Un modérateur peut être un utilisateur externe
# -> Accès via "join.cgi" / hash propre à chaque participant
for moderator in ${conf_moderators} ; do

	hash=$(gen_meeting_hash)

	cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','${hash}','moderator','${moderator}');
EOT

done

# Table attendees (guest)
# Un invité ne doit pas s'authentifier même si c'est un utilisateur interne
# -> Accès via "join.cgi" / hash propre à chaque participant
for guest in ${conf_guests} ; do

	hash=$(gen_meeting_hash)

	cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','${hash}','guest','${guest}');
EOT

done

# Enregistrement des données
cat ${JMB_CGI_TMP}/${tsn}.sql |sqlite3 ${JMB_DB}
rm ${JMB_CGI_TMP}/${tsn}.sql

log "booking.cgi: new: meeting_name='${conf_name}', meeting_id='${tsn}', auth_uid='${auth_uid}'"
