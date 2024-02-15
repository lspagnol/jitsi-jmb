#!/bin/bash

########################################################################
# GCI (booking.cgi): suppression d'une réunion
########################################################################

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_editor=0" -> non, "is_editor=1" -> oui
set_is_editor

if [ "${is_editor}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à supprimer une réunion"
fi

# Le timestamp est l'ID de réunion
tsn=${conf_tsn}

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

# Récupérer les données
get_meeting_infos ${tsn}

if [ "${owner}" != "${auth_mail}" ] ; then
	http_403 "Vous n'etes pas le propriétaire de cette réunion"
fi

# Vérification passée, on peut supprimer les données
source ${JMB_PATH}/inc/register_sql_del.sh

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
