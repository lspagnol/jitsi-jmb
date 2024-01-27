#!/bin/bash

########################################################################
# GCI (booking.cgi): suppression d'une réunion
########################################################################

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_allowed=0" -> non, "is_allowed=1" -> oui
set_is_allowed
if [ "${is_allowed}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à supprimer une réunion"
fi

# Le timestamp est l'ID de réunion
tsn=${conf_tsn}

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

# Récupérer les données
source ${JMB_BOOKING_DATA}/${tsn}

url_redirect="${JMB_DEFAULT_URL_REDIRECT}"

if [ "${owner}" != "${auth_mail}" ] ; then
	http_403 "Vous n'etes pas le propriétaire de cette réunion"
fi

# Vérification passée, on peut supprimer les données
rm ${JMB_BOOKING_DATA}/${tsn}
rm ${JMB_MAIL_REMINDER_DATA}/${tsn}.* 2>/dev/null
rm ${JMB_XMPP_REMINDER_DATA}/${tsn}.* 2>/dev/null

tpl_owner="${JMB_PATH}/inc/mail_del_owner.sh"
tpl_guest="${JMB_PATH}/inc/mail_del_guest.sh"
subject_owner="$(utf8_to_mime ${JMB_SUBJECT_DEL_OWNER})"
subject_guest="$(utf8_to_mime ${JMB_SUBJECT_DEL_GUEST})"

# Mail de notification au demandeur
source ${tpl_owner} |mail\
 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
 -a "Content-Transfer-Encoding: 8bit"\
 -a "Content-Language: fr"\
 -a "from: ${JMB_MAIL_FROM_NOTIFICATION}"\
 -a "subject: ${subject_owner}"\
  ${auth_mail}

# Mail de notification aux invités
for guest in ${conf_guests} ; do

	source ${tpl_guest} |mail\
	 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
	 -a "Content-Transfer-Encoding: 8bit"\
	 -a "Content-Language: fr"\
	 -a "from: ${auth_mail}"\
	 -a "subject: ${subject_guest}"\
	 ${guest}

done

# Afficher la page Web de confirmation de la suppression
source ${JMB_PATH}/inc/page_register_del.sh >> ${out}

http_200
