#!/bin/bash

########################################################################
# Notification par mail (nouvelle réunion ou modification réunion)
########################################################################

# Mail de notification au demandeur
source ${tpl_mail_owner} |mail\
 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
 -a "Content-Transfer-Encoding: 8bit"\
 -a "Content-Language: fr"\
 -a "from: ${JMB_MAIL_FROM_NOTIFICATION}"\
 -a "subject: ${subject_mail_owner}"\
  ${HTTP_MAIL}

# Mail d'invitation aux invités
if [ "${conf_date}" != "${old_conf_date}" ]\
 || [ "${conf_time}" != "${old_conf_time}" ] ; then
    # Modification -> notifier tout le monde

	for guest in ${conf_guests} ; do

		echo " ${old_conf_guests} " | grep -q " ${guest} "
		if [ ${?} -eq 0 ] ; then
			# Déjà invité -> template "edit"
			subject_mail_guest="${JMB_SUBJECT_EDIT_GUEST}"
			tpl_mail_guest="${JMB_PATH}/inc/mail_edit_guest.sh"
		else
			# Pas encore invité -> template "new"
			subject_mail_guest="${JMB_SUBJECT_NEW_GUEST}"
			tpl_mail_guest="${JMB_PATH}/inc/mail_new_guest.sh"
		fi

		source ${tpl_mail_guest} |mail\
		 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
		 -a "Content-Transfer-Encoding: 8bit"\
		 -a "Content-Language: fr"\
		 -a "from: ${HTTP_MAIL}"\
		 -a "subject: ${subject_mail_guest}"\
		 ${guest}

	done

else
	# Pas de modification de date, heure ou durée -> notifier les nouveaux invités

	subject_mail_guest="${JMB_SUBJECT_NEW_GUEST}"
	tpl_mail_guest="${JMB_PATH}/inc/mail_new_guest.sh"

	for guest in ${conf_guests} ; do

		echo " ${old_conf_guests} " | grep -q " ${guest} "
		if [ ${?} -ne 0 ] ; then

			source ${tpl_mail_guest} |mail\
			 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
			 -a "Content-Transfer-Encoding: 8bit"\
			 -a "Content-Language: fr"\
			 -a "from: ${HTTP_MAIL}"\
			 -a "subject: ${subject_mail_guest}"\
			 ${guest}

		fi

	done
fi
