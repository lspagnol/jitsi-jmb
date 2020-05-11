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

tpl_mail_owner="${JMB_PATH}/inc/mail_del_owner.sh"
tpl_mail_guest="${JMB_PATH}/inc/mail_del_guest.sh"
subject_mail_owner="${JMB_SUBJECT_DEL_OWNER}"
subject_mail_guest="${JMB_SUBJECT_DEL_GUEST}"

[ -f ${JMB_BOOKING_DATA}/${tsn} ] && rm ${JMB_BOOKING_DATA}/${tsn}

source ${JMB_PATH}/lib/mail.sh
source ${JMB_PATH}/inc/form_register_del.sh >> ${out}
http_200
