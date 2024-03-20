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

# URL de redirection après l'enregistrement de la conférence
if [ ${now} -ge ${begin} ] ; then
	url_redirect="/${conf_name}"
else
	url_redirect="${JMB_DEFAULT_URL_REDIRECT}"
fi

if [ ${begin} -lt ${now} ] ; then
	http_403 "Données non enregistrées: la date de la réunion est antérieure à la date actuelle"
fi

if [ "${conf_duration}" = "" ] ; then
	http_403 "Données non enregistrées: vous n'avez pas indiqué la durée de la réunion"
elif [ "${conf_duration}" = "0" ] ; then
	http_403 "Données non enregistrées: la durée d'une réunion ne peut pas être nulle"
elif [[ "${conf_duration}" =~ ^- ]] ; then
	http_403 "Données non enregistrées: la durée d'une réunion ne peut pas être négative"
fi

# Calul durée
duration=$(( ${conf_duration} * 60 ))

if [ "${duration}" = "0" ] ; then
	# Si la durée saisie n'est pas un nombre, le résultat de la multiplication est "0"
	http_403 "Données non enregistrées: la durée de la réunion est incorrecte"
fi

########################################################################

end=$(( ${begin} + ${duration} ))

# Remplacer l'adresse mail secondaire des modérateurs par leur adresse principale
conf_moderators=$(fix_mailAliases ${conf_moderators})

# On vérifie le nombre de modérateurs
n=$(echo ${conf_moderators} |wc -w)
if [ ${n} -gt ${JMB_MAX_MODERATORS} ] ; then
	http_403 "Données non enregistrées: vous avez indiqué ${n} modérateurs (le maximum est ${JMB_MAX_MODERATORS})"
fi

# Remplacer 'adresse mail secondaire des invités par leur adresse principale
conf_guests=$(fix_mailAliases ${conf_guests})

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

########################################################################

# Préparation des rappels / mail
if [ ! -z "${JMB_MAIL_REMINDER}" ] ; then

	cat<<EOT > ${JMB_CGI_TMP}/${tsn}.sql
DELETE FROM mail_reminder WHERE mail_reminder_meeting_id='${tsn}';
EOT

	for r in ${JMB_MAIL_REMINDER} ; do
		reminder=$(( ${begin} - ( ${r} * 60 ) ))
		if [ ${reminder} -gt ${now} ] ; then
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO mail_reminder (mail_reminder_meeting_id,mail_reminder_date,mail_reminder_done)
VALUES ('${tsn}','${reminder}','0');
EOT
		fi
	done

fi

########################################################################

# Préparation des rappels / XMPP

if [ ! -z "${JMB_XMPP_REMINDER}" ] ; then

	cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
DELETE FROM xmpp_reminder WHERE xmpp_reminder_meeting_id='${tsn}';
EOT

	for r in ${JMB_XMPP_REMINDER} ; do
		reminder=$(( ${end} - ( ${r} * 60 ) ))
		if [ ${reminder} -gt ${now} ] ; then
			cat<<EOT >> ${JMB_CGI_TMP}/${tsn}.sql
INSERT INTO xmpp_reminder (xmpp_reminder_meeting_id,xmpp_reminder_date,xmpp_reminder_done)
VALUES ('${tsn}','${reminder}','0');
EOT
		fi
	done

fi
