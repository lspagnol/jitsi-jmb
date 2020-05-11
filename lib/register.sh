#!/bin/bash

########################################################################
# GCI (booking.cgi): enregistrement d'une réunion
# -> module commun appelé par register_edit ou register_new
########################################################################

# Récupérer le TSZ du formulaire
tsn=${conf_tsn}

########################################################################

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

if [ -z "${conf_name}" ] ; then
	# Aucune donnée du formulaire -> appel direct de l'URL ?
	url_redirect="${JMB_DEFAULT_URL_REDIRECT}"
	# Envoyer le contenu HTML de la réservation vide
	source ${JMB_PATH}/inc/form_register_error.sh >> ${out}
	http_200
fi

########################################################################

# Calcul timestam début
begin=$(date -d "${conf_date} ${conf_time}" +%s)

# Calul durée
duration=$(( ${conf_duration} * 60 ))

# URL de redirection après l'enregistrement de la conférence
if [ ${now} -ge ${begin} ] ; then
	url_redirect="/${conf_name}"
else
	url_redirect="${JMB_DEFAULT_URL_REDIRECT}"
fi

########################################################################

# Enregistrement des données du formulaire
cat<<EOT > ${JMB_BOOKING_DATA}/${tsn}
name=${conf_name}
mail_owner=${HTTP_MAIL}
begin=${begin}
duration=${duration}
end=$(( ${begin} + ${duration} ))
object='${object}'
guests='${conf_guests}'
EOT

# Enregistrement des rappels par mail
if [ ! -z "${JMB_MAIL_REMINDER}" ] ; then
	rm ${JMB_MAIL_REMINDER_DATA}/${tsn}.* 2>/dev/null
	for r in ${JMB_MAIL_REMINDER} ; do
		reminder=$(( ${begin} - ( ${r} * 60 ) ))
		if [ "${reminder}" -gt "${now}" ] ; then
			cat<<EOT > ${JMB_MAIL_REMINDER_DATA}/${tsn}.${r}
reminder=${reminder}
booking_tsn=${tsn}
SERVER_NAME=${SERVER_NAME}
JMB_MAIL_DOMAIN=${JMB_MAIL_DOMAIN}
EOT
		fi
	done
fi
