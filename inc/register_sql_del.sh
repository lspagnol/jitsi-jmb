########################################################################
# Suppression réunion / SQLite
########################################################################

# Table "meetings"
cat<<EOT > ${JMB_CGI_TMP}/${tsn}.sql
DELETE FROM meetings
WHERE meeting_id='${tsn}';
EOT

# Enregistrement des données
cat ${JMB_CGI_TMP}/${tsn}.sql |sqlite3 ${JMB_DB}
rm ${JMB_CGI_TMP}/${tsn}.sql

log "booking.cgi: del: meeting_name='${conf_name}', meeting_id='${tsn}', auth_uid='${auth_uid}'"
