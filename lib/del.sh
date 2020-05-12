#!/bin/bash

########################################################################
# GCI (booking.cgi): suppression d'une réunion
########################################################################

# Le timestamp est l'ID de réunion
tsn=${conf_tsn}

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

# Récupérer les données
source ${JMB_BOOKING_DATA}/${tsn}

url_redirect="${JMB_DEFAULT_URL_REDIRECT}"

if [ "${mail_owner}" != "${HTTP_MAIL}" ] ; then
        http_403 "Vous n'etes pas le propriétaire de cette réunion"
fi

# Vérification passée, on peut supprimer les données
[ -f ${JMB_BOOKING_DATA}/${tsn} ] && rm ${JMB_BOOKING_DATA}/${tsn}

tpl_mail_owner="${JMB_PATH}/inc/mail_del_owner.sh"
tpl_mail_guest="${JMB_PATH}/inc/mail_del_guest.sh"
subject_mail_owner="${JMB_SUBJECT_DEL_OWNER}"
subject_mail_guest="${JMB_SUBJECT_DEL_GUEST}"

# Mail de notification au demandeur
source ${tpl_mail_owner} |mail\
 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
 -a "Content-Transfer-Encoding: 8bit"\
 -a "Content-Language: fr"\
 -a "from: ${JMB_MAIL_FROM_NOTIFICATION}"\
 -a "subject: ${subject_mail_owner}"\
  ${HTTP_MAIL}

# Mail de notification aux invités
for guest in ${conf_guests} ; do

	source ${tpl_mail_guest} |mail\
	 -a "Content-Type: text/plain; charset=utf-8; format=flowed"\
	 -a "Content-Transfer-Encoding: 8bit"\
	 -a "Content-Language: fr"\
	 -a "from: ${HTTP_MAIL}"\
	 -a "subject: ${subject_mail_guest}"\
	 ${guest}

done

# Afficher la page Web de confirmation de la suppression
source ${JMB_PATH}/inc/page_register_del.sh >> ${out}

http_200
