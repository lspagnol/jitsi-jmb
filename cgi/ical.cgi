#!/bin/bash

########################################################################
# CGI du flux iCal
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

cat<<EOT
BEGIN:VEVENT
DTSTAMP:${dtstamp}
UID:${f}
ORGANIZER:MAILTO:${mail_owner}
STATUS:CONFIRMED
SUMMARY:${object}
DTSTART;TZID=Europe/Paris:${dtstart}
DTEND;TZID=Europe/Paris:${dtend}
LOCATION:${JMB_SCHEME}://${SERVER_NAME}/${name}
EOT

for reminder in ${JMB_MAIL_REMINDER} ; do
cat <<EOT
BEGIN:VALARM
ACTION:DISPLAY
TRIGGER:-P${reminder}M
DESCRIPTION:${object}
END:VALARM
EOT
done

cat<<EOT
END:VEVENT
EOT

echo
}

########################################################################

# Lecture du hash passé dans l'URL
echo "${QUERY_STRING}"\
 |tr -d -c '[:alnum:]&'\
 |sed 's/&.*//g'\
  > ${JMB_CGI_TMP}/query.${tsn}
ical_hash=$(<${JMB_CGI_TMP}/query.${tsn})
rm ${JMB_CGI_TMP}/query.${tsn}

# Paramètres du flux iCal
cat<<EOT > ${out}
BEGIN:VCALENDAR
PRODID:-//Jisti-jmb
VERSION:2.0

NAME:${JMB_ICAL_NAME}
X-WR-CALNAME:${JMB_ICAL_NAME}

DESCRIPTION:${JMB_ICAL_DESC}
X-WR-CALDESC:${JMB_ICAL_DESC}

REFRESH-INTERVAL;VALUE=DURATION:${JMB_ICAL_REFRESH}
X-PUBLISHED-TTL:${JMB_ICAL_REFRESH}

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

# Hash dans l'URL ?
if [ ! -z "${ical_hash}" ] ; then

	# Le hash existe ?
	if [ -f ${JMB_ICAL_DATA}/by-hash/${ical_hash} ] ; then

		# Récupérer l'identifiant qui correspond au hash
		uid=$(<${JMB_ICAL_DATA}/by-hash/${ical_hash})
		
		# Récupérer la liste des adresses mail de l'utilisateur
		mails=$($JMB_LDAPSEARCH uid=${uid} mail mailAlternateAddress |egrep '^(mail|mailAlternateAddress):' |awk '{print $2}')
		mails=$(echo ${mails} |sed 's/ /|/g')

		# Générer la liste des évennements
		for f in $(ls -1 ${JMB_BOOKING_DATA}/ 2>/dev/null |sort -n) ; do

			unset name mail_owner begin duration end object guests

			dtstamp=$(stat -c "%Y" ${JMB_BOOKING_DATA}/${f})
			dtstamp=$(date -d@${dtstamp} "+%Y%m%dT%H%M00Z")

			source ${JMB_BOOKING_DATA}/${f}

			echo " ${guests} " |egrep -q " (${mails}) "
			if [ ${?} -eq 0 ] ; then
				is_guest=1
			fi

			echo " ${mail_owner} " |egrep -q " (${mails}) "
			if [ ${?} -eq 0 ] ; then
				is_owner=1
			fi

			if [ "${is_owner}" = "1" ] || [ "${is_guest}" = "1" ] ; then

				if [ ! -z "${begin}" ] ; then
					dtstart=$(date -d@${begin} "+%Y%m%dT%H%M00")
				fi
				if [ ! -z "${duration}" ] ; then
					dtend=$(( ${begin} + ${duration} ))
					dtend=$(date -d@${dtend} "+%Y%m%dT%H%M00")
				fi

				out_ical >> ${out}

			fi

		done

	fi
fi

cat<<EOT >> ${out}
END:VCALENDAR
EOT

http_200_ical

