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

# Sélection du template "annulation d'une réunion"
mail_tpl="${JMB_PATH}/inc/mail_tpl_del.sh"

# Mail de notification au demandeur
role="owner"
mailto="${auth_mail}"
subject="$(utf8_to_mime ${JMB_SUBJECT_DEL_OWNER})"
source ${mail_tpl} |mail\
 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
 -a "Content-Transfer-Encoding: 8bit"\
 -a "Content-Language: fr"\
 -a "from: ${JMB_MAIL_FROM_NOTIFICATION}"\
 -a "subject: ${subject}"\
  ${mailto}

# Mail de notification aux invités
role=guest
subject="$(utf8_to_mime ${JMB_SUBJECT_DEL_GUEST})"
for mailto in ${conf_guests} ; do
	source ${mail_tpl} |mail\
	 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
	 -a "Content-Transfer-Encoding: 8bit"\
	 -a "Content-Language: fr"\
	 -a "from: ${auth_mail}"\
	 -a "subject: ${subject}"\
	 ${mailto}
done

# Mail de notification aux modérateurs
role=moderator
subject="$(utf8_to_mime ${JMB_SUBJECT_DEL_MODERATOR})"
for mailto in ${conf_moderators} ; do
	source ${mail_tpl} |mail\
	 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
	 -a "Content-Transfer-Encoding: 8bit"\
	 -a "Content-Language: fr"\
	 -a "from: ${auth_mail}"\
	 -a "subject: ${subject}"\
	 ${mailto}
done

# Afficher la page Web de confirmation de la suppression
source ${JMB_PATH}/inc/page_register_del.sh >> ${out}

http_200
