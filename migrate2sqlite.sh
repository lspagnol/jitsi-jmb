#!/bin/bash

#-----------------------------------------------------------------------
# Import données (fichier plats) / migration -> SQLite
#-----------------------------------------------------------------------

# Stockage des données
JMB_DATA="/var/www/jitsi-jmb"

# Stockage des données temporaires des CGIs
JMB_CGI_TMP="${JMB_DATA}/tmp"

# Stockage des données (SQLite)
JMB_DB="${JMB_DATA}/data/jitsi-jmb.db"

# Stockage des données de réservation
JMB_BOOKING_DATA=${JMB_DATA}/booking

# Destination d'archivage des données de réservation
JMB_BOOKING_ARCHIVE=${JMB_DATA}/booking_archive

# Stockage des reminders / mail
JMB_MAIL_REMINDER_DATA="${JMB_DATA}/mail_reminder"

# Stockage des reminders / XMPP
JMB_XMPP_REMINDER_DATA="${JMB_DATA}/xmpp_reminder"

# Stockage des données iCal
JMB_ICAL_DATA="${JMB_DATA}/ical"

#-----------------------------------------------------------------------

function import_tsn {

#name=jeuquoovaith
#mail_owner=ophelie.petiot@univ-reims.fr
#begin=1707386400
#duration=3600
#end=1707390000
#object="Mémoire Koleti"
#guests="koletivaitanaki@gmail.com"

# Table "meetings"
cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO meetings (meeting_id,meeting_name,meeting_object,meeting_begin,meeting_duration,meeting_end) 
VALUES ('${tsn}','${name}','${object}','${begin}','${duration}','${end}');
EOT

# Table attendees (owner)
# Le hash est inutile car le propriétaire peut forcément s'authentifier
# -> Accès direct via "token.cgi"
cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','','owner','${mail_owner}');
EOT

# Table attendees (guest)
# Un invité ne doit pas s'authentifier même si c'est un utilisateur interne
# -> Accès via "join.cgi" / hash propre à chaque participant
for guest in ${guests} ; do

	gen_meeting_hash

	cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO attendees (attendee_meeting_id,attendee_meeting_hash,attendee_role,attendee_email)
VALUES ('${tsn}','${hash}','guest','${guest}');
EOT

done

# Enregistrement des données
cat ${JMB_CGI_TMP}/${tsn}.sql |sqlite3 ${JMB_DB}
rm ${JMB_CGI_TMP}/${tsn}.sql

}

function gen_meeting_hash {
# Générer un hash de réunion
# Variable en retour:
# hash

hash=$(pwgen -s -0 16 1)

}

#-----------------------------------------------------------------------

# Import des données iCal

for user in $(ls -1 ${JMB_ICAL_DATA}/by-user/) ; do
	hash=$(<${JMB_ICAL_DATA}/by-user/${user})
	sqlite3 ${JMB_DB} "INSERT INTO ical (ical_owner,ical_hash) values ('${user}','${hash}');"
done

#-----------------------------------------------------------------------

# Import des réunions

for tsn in $(ls -1 ${JMB_BOOKING_DATA}) ; do

	unset name mail_owner begin duration end object guests

	source ${JMB_BOOKING_DATA}/${tsn}
	import_tsn

done

for tsn in $(ls -1 ${JMB_BOOKING_ARCHIVE}) ; do

	unset name mail_owner begin duration end object guests

	source ${JMB_BOOKING_ARCHIVE}/${tsn}
	import_tsn

done
