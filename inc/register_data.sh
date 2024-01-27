########################################################################
# Enregistrement des données de réunion
########################################################################

# Récupérer le TSN du formulaire
tsn=${conf_tsn}

########################################################################

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

if [ -z "${conf_name}" ] ; then
	# Aucune donnée du formulaire -> appel direct de l'URL ?
	http_403 "Aucune donnée à enregistrer"
fi

########################################################################

# Calcul timestam début
begin=$(date -d "${conf_date} ${conf_time}" +%s)

if [ ${begin} -lt ${now} ] ; then
	http_403 "Données non enregistrées: la date de la réunion est antérieure à la date actuelle"
fi

# Calul durée
duration=$(( ${conf_duration} * 60 ))

# URL de redirection après l'enregistrement de la conférence
if [ ${now} -ge ${begin} ] ; then
	url_redirect="/${conf_name}"
else
	url_redirect="${JMB_DEFAULT_URL_REDIRECT}"
fi

########################################################################

end=$(( ${begin} + ${duration} ))

# On vérifie le nombre de modérateurs
n=$(echo ${conf_moderators} |wc -w)
if [ ${n} -gt ${JMB_MAX_MODERATORS} ] ; then
	http_403 "Données non enregistrées: vous avez indiqué ${n} modérateurs (le maximum est ${JMB_MAX_MODERATORS})"
fi

# Expansion liste invités abonnés à liste de diffusion
conf_guests=$(expand_list_subscribers ${conf_guests})

# On vérifie le nombre d'invités
n=$(echo ${conf_guests} |wc -w)
if [ ${n} -eq 0 ] ; then
	http_403 "Données non enregistrées: vous n'avez indiqué aucun invité"
fi

if [ ${n} -gt ${JMB_MAX_GUESTS} ] ; then
	http_403 "Données non enregistrées: vous avez indiqué ${n} invités (le maximum est ${JMB_MAX_GUESTS})"
fi

# Enregistrement des données du formulaire
cat<<EOT > ${JMB_BOOKING_DATA}/${tsn}
name=${conf_name}
owner=${auth_mail}
begin=${begin}
duration=${duration}
end=${end}
object="${object}"
moderators="${conf_moderators}"
guests="${conf_guests}"
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
SERVER_NAME=${JMB_SERVER_NAME}
JMB_MAIL_DOMAIN=${JMB_MAIL_DOMAIN}
EOT
		fi
	done
fi

# Enregistrement des rappels par XMPP
if [ ! -z "${JMB_XMPP_REMINDER_DATA}" ] ; then
	rm ${JMB_XMPP_REMINDER_DATA}/${tsn}.* 2>/dev/null
	for r in ${JMB_XMPP_REMINDER} ; do
		reminder=$(( ${end} - ( ${r} * 60 ) ))
		cat<<EOT > ${JMB_XMPP_REMINDER_DATA}/${tsn}.${r}
reminder=${reminder}
booking_tsn=${tsn}
grace=${r}
SERVER_NAME=${JMB_SERVER_NAME}
EOT
	done
fi
