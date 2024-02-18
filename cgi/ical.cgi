#!/bin/bash

########################################################################
# CGI du flux iCal
# Définition attributs -> https://www.kanzaki.com/docs/ical/
########################################################################

# Timestamps
now=$(date +%s)
tsn=$(date +%s%N)

########################################################################

# Charger la configuration et les fonctions
JMB_PATH=/opt/jitsi-jmb
source ${JMB_PATH}/etc/jmb.cf
source ${JMB_PATH}/lib/jmb.lib

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

function out_ical {

# Note: le CN est obligatoire pour Thunderbird !
local cn
cn=${owner%@*}
cn=${cn//./ }
cn=${cn^^}

cat<<EOT
BEGIN:VEVENT
DTSTAMP:${dtstamp}
UID:${f}
STATUS:CONFIRMED
SUMMARY:${object}
LOCATION:${location}
DTSTART;TZID=Europe/Paris:${dtstart}
DTEND;TZID=Europe/Paris:${dtend}
ORGANIZER;PARTSTAT=ACCEPTED;CN=${cn};MAILTO:${owner}
EOT

# PARTSTAT=NEEDS-ACTION -> attendee_partstat=0
# PARTSTAT=ACCEPTED     -> attendee_partstat=1
# PARTSTAT=DECLINED     -> attendee_partstat=2

if [ "${is_owner}" = "1" ] ; then
	# Proprio de la réunion -> ajouter la liste des invités et des modérateurs
	for attendee in ${moderators} ${guests} ; do
		partstat=$(sqlite3 ${JMB_DB} "SELECT DISTINCT attendee_partstat FROM attendees WHERE attendee_meeting_id='${f}' AND attendee_email='${attendee}';")
		case ${partstat} in
			0|"")
				partstat="NEEDS-ACTION"
			;;
			1)
				partstat="ACCEPTED"
			;;
			2)
				partstat="DECLINED"
			;;
		esac
		cn=${attendee%@*}
		cn=${cn//./ }
		cn=${cn^^}
		echo "ATTENDEE;CUTYPE=INDIVIDUAL;PARTSTAT=${partstat};ROLE=REQ-PARTICIPANT;RSVP=TRUE;SCHEDULE-STATUS=1.1;CN=${cn};MAILTO:${attendee}"
	done
fi

for reminder in ${JMB_MAIL_REMINDER} ; do
	# ICSx5 ne supporte pas les "reminders dans le passé"
	if [ ${now} -lt $(( ${begin} - (${reminder}*60) )) ] ; then
cat <<EOT
BEGIN:VALARM
ACTION:DISPLAY
TRIGGER:-PT${reminder}M
DESCRIPTION:${object}
END:VALARM
EOT
	fi
done

cat<<EOT
END:VEVENT
EOT
}

########################################################################

# Lecture du hash passé dans l'URL
echo "${QUERY_STRING}"\
 |tr -d -c '[:alnum:]&'\
 |sed 's/&.*//g'\
  > ${JMB_CGI_TMP}/query.${tsn}
ical_hash=$(<${JMB_CGI_TMP}/query.${tsn})
rm ${JMB_CGI_TMP}/query.${tsn}

# Hash dans l'URL ?
if [ ! -z "${ical_hash}" ] ; then

	# Paramètres du flux iCal
	cat<<EOT |awk -v ORS='\r\n' 1 > ${out}
BEGIN:VCALENDAR
PRODID:-//Jisti-jmb
VERSION:2.0
NAME:${JMB_ICAL_NAME}
DESCRIPTION:${JMB_ICAL_DESC}
X-WR-CALNAME:${JMB_ICAL_NAME}
X-WR-CALDESC:${JMB_ICAL_DESC}
BEGIN:VTIMEZONE
TZID:${JMB_ICAL_TZID}
X-LIC-LOCATION:${JMB_ICAL_TZID}
BEGIN:DAYLIGHT
TZOFFSETFROM:+0100
TZOFFSETTO:+0200
TZNAME:CEST
DTSTART:19700329T020000
RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=3
END:DAYLIGHT
BEGIN:STANDARD
TZOFFSETFROM:+0200
TZOFFSETTO:+0100
TZNAME:CET
DTSTART:19701025T030000
RRULE:FREQ=YEARLY;BYDAY=-1SU;BYMONTH=10
END:STANDARD
END:VTIMEZONE
EOT

	# Chercher l'identifiant correspondant au hash
	uid=$(sqlite3 ${JMB_DB} "SELECT ical_owner FROM ical WHERE ical_hash='${ical_hash}';")

	# Le hash/uid existe ?
	if [ ! -z "${uid}" ] ; then

		# Récupérer la liste des adresses mail de l'utilisateur
		# FIXME -> les identifiants ne fonctionnent que pour les utilisateurs
		#          présents dans le référentiel LDAP, il faudrait passer
		#          à un autre attribut pour les utilisateurs d'une fédération d'identité
		auth_mail=$($JMB_LDAPSEARCH uid=${uid} mail |grep '^mail:')
		auth_mail=${auth_mail#* }

		# Générer la liste des évènements
		for f in $(\
			sqlite3 ${JMB_DB} "\
				SELECT DISTINCT meetings.meeting_id FROM meetings
				INNER JOIN attendees ON meetings.meeting_id=attendees.attendee_meeting_id
				WHERE meetings.meeting_end > '${now}' AND attendees.attendee_email='${auth_mail}';") ; do

			unset name owner begin duration end object guests moderators is_guest is_owner is_moderator hash location

			# Récupérer les infos de la réunion
			get_meeting_infos ${f}

			dtstamp=$(date -d@${create} "+%Y%m%dT%H%M00")

			# Au cas ou le participant serait enregistré plusieurs fois (avec des rôles différents),
			# c'est le rôle le plus élevé qui sera sélectionné pour le flux iCal.

			echo " ${guests} " |grep -q " ${auth_mail} "
			if [ ${?} -eq 0 ] ; then
				hash=$(get_meeting_hash ${f} ${auth_mail} guest)
				location="https://${JMB_SERVER_NAME}/join.cgi?id=${hash}"
			fi

			echo " ${moderators} " |grep -q " ${auth_mail} "
			if [ ${?} -eq 0 ] ; then
				hash=$(get_meeting_hash ${f} ${auth_mail} moderator)
				location="https://${JMB_SERVER_NAME}/join.cgi?id=${hash}"
			fi

			echo " ${owner} " |grep -q " ${auth_mail} "
			if [ ${?} -eq 0 ] ; then
				is_owner=1
				hash=$(get_meeting_hash ${f} ${auth_mail} owner)
				location="https://${JMB_SERVER_NAME}/token.cgi?room=${name}"
			fi

			if [ ! -z "${location}" ]  ;then

				if [ ! -z "${begin}" ] ; then
					dtstart=$(date -d@${begin} "+%Y%m%dT%H%M00")
				fi
				if [ ! -z "${duration}" ] ; then
					dtend=$(( ${begin} + ${duration} ))
					dtend=$(date -d@${dtend} "+%Y%m%dT%H%M00")
				fi

				out_ical |awk -v ORS='\r\n' 1 >> ${out}

			fi

		done

	fi
fi

cat<<EOT |awk -v ORS='\r\n' 1 >> ${out}
END:VCALENDAR
EOT

http_200_ical

