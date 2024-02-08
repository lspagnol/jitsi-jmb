########################################################################
# Notification par mail (nouvelle réunion ou modification réunion)
########################################################################

# Mail de notification au demandeur
role="owner"
mailto="${auth_mail}"
source ${mail_tpl} |mail\
	-a "Content-Type: text/plain; charset=utf-8; format=flowed"\
	-a "Content-Transfer-Encoding: 8bit"\
	-a "Content-Language: fr"\
	-a "From: ${JMB_MAIL_FROM_NOTIFICATION}"\
	-a "Subject: ${subject}"\
	${mailto}

# Si l'adresse de l'organisateur ne correspond pas au domaine du serveur
# Jitsi, on remplace l'adresse d'enveloppe pour passer les contrôles SPF
echo "${auth_mail}" |egrep -q "${JMB_MAIL_DOMAIN//\./\\.}$"
if [ $? -eq 0 ] ; then
	envelope_from="${auth_mail}"
else
	envelope_from="${JMB_MAIL_FROM_NOTIFICATION}"
fi

# Mail d'invitation aux invités & modérateurs
if [ "${conf_date}" != "${old_conf_date}" ] || [ "${conf_time}" != "${old_conf_time}" ] ; then

	# Modification date|heure -> notifier les invités et les modérateurs

	role="guest"
	for mailto in ${conf_guests} ; do

		get_meeting_hash ${tsn} ${mailto} ${role}

		echo " ${old_conf_guests} " | grep -q " ${mailto} "
		if [ ${?} -eq 0 ] ; then
			# Déjà invité -> template "edit"
			subject="$(utf8_to_mime ${JMB_SUBJECT_EDIT_GUEST})"
			mail_tpl="${JMB_PATH}/inc/mail_tpl_edit.sh"
		else
			# Pas encore invité -> template "new"
			subject="$(utf8_to_mime ${JMB_SUBJECT_NEW_GUEST})"
			mail_tpl="${JMB_PATH}/inc/mail_tpl_new.sh"
		fi

		source ${mail_tpl} |mail\
			-r "${envelope_from}"\
			-a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			-a "Content-Transfer-Encoding: 8bit"\
			-a "Content-Language: fr"\
			-a "From: ${auth_mail}"\
			-a "Subject: ${subject}"\
			${mailto}

	done

	role="moderator"
	for mailto in ${conf_moderators} ; do

		get_meeting_hash ${tsn} ${mailto} ${role}

		echo " ${old_conf_moderators} " | grep -q " ${mailto} "
		if [ ${?} -eq 0 ] ; then
			# Déjà invité -> template "edit"
			subject="$(utf8_to_mime ${JMB_SUBJECT_EDIT_MODERATOR})"
			mail_tpl="${JMB_PATH}/inc/mail_tpl_edit.sh"
		else
			# Pas encore invité -> template "new"
			subject="$(utf8_to_mime ${JMB_SUBJECT_NEW_MODERATOR})"
			mail_tpl="${JMB_PATH}/inc/mail_tpl_new.sh"
		fi

		source ${mail_tpl} |mail\
			-r "${envelope_from}"\
			-a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			-a "Content-Transfer-Encoding: 8bit"\
			-a "Content-Language: fr"\
			-a "From: ${auth_mail}"\
			-a "Subject: ${subject}"\
			${mailto}

	done


else

	# Pas de modification de date|heure -> notifier les nouveaux invités
	# et les nouveaux modérateurs

	mail_tpl="${JMB_PATH}/inc/mail_tpl_new.sh"

	role="guest"
	subject="$(utf8_to_mime ${JMB_SUBJECT_NEW_GUEST})"
	for mailto in ${conf_guests} ; do

		echo " ${old_conf_guests} " | grep -q " ${mailto} "
		if [ ${?} -ne 0 ] ; then

			source ${mail_tpl} |mail\
				-r "${envelope_from}"\
				-a "Content-Type: text/plain; charset=utf-8; format=flowed"\
				-a "Content-Transfer-Encoding: 8bit"\
				-a "Content-Language: fr"\
				-a "From: ${auth_mail}"\
				-a "Subject: ${subject}"\
				${mailto}

		fi

	done

	role="moderator"
	subject="$(utf8_to_mime ${JMB_SUBJECT_NEW_MODERATOR})"
	for mailto in ${conf_moderators} ; do

		echo " ${old_conf_moderators} " | grep -q " ${mailto} "
		if [ ${?} -ne 0 ] ; then

			source ${mail_tpl} |mail\
				-r "${envelope_from}"\
				-a "Content-Type: text/plain; charset=utf-8; format=flowed"\
				-a "Content-Transfer-Encoding: 8bit"\
				-a "Content-Language: fr"\
				-a "From: ${auth_mail}"\
				-a "Subject: ${subject}"\
				${mailto}

		fi

	done

fi
