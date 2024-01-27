########################################################################
# Notification par mail (nouvelle réunion ou modification réunion)
########################################################################

# Mail de notification au demandeur
source ${tpl_owner} |mail\
 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
 -a "Content-Transfer-Encoding: 8bit"\
 -a "Content-Language: fr"\
 -a "From: ${JMB_MAIL_FROM_NOTIFICATION}"\
 -a "Subject: ${subject_owner}"\
  ${auth_mail}

# Mail d'invitation aux invités
if [ "${conf_date}" != "${old_conf_date}" ]\
 || [ "${conf_time}" != "${old_conf_time}" ] ; then

	# Modification date|heure -> notifier tout le monde

	for guest in ${conf_guests} ; do

		echo " ${old_conf_guests} " | grep -q " ${guest} "
		if [ ${?} -eq 0 ] ; then
			# Déjà invité -> template "edit"
			subject_guest="$(utf8_to_mime ${JMB_SUBJECT_EDIT_GUEST})"
			tpl_guest="${JMB_PATH}/inc/mail_edit_guest.sh"
		else
			# Pas encore invité -> template "new"
			subject_guest="$(utf8_to_mime ${JMB_SUBJECT_NEW_GUEST})"
			tpl_guest="${JMB_PATH}/inc/mail_new_guest.sh"
		fi

		source ${tpl_guest} |mail\
		 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
		 -a "Content-Transfer-Encoding: 8bit"\
		 -a "Content-Language: fr"\
		 -a "From: ${auth_mail}"\
		 -a "Subject: ${subject_guest}"\
		 ${guest}

	done

else

	# Pas de modification de date|heure -> notifier les nouveaux invités

	subject_guest="$(utf8_to_mime ${JMB_SUBJECT_NEW_GUEST})"
	tpl_guest="${JMB_PATH}/inc/mail_new_guest.sh"

	for guest in ${conf_guests} ; do

		echo " ${old_conf_guests} " | grep -q " ${guest} "
		if [ ${?} -ne 0 ] ; then

			source ${tpl_guest} |mail\
			 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			 -a "Content-Transfer-Encoding: 8bit"\
			 -a "Content-Language: fr"\
			 -a "From: ${auth_mail}"\
			 -a "Subject: ${subject_guest}"\
			 ${guest}

		fi

	done

fi
