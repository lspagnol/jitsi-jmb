#!/bin/bash

########################################################################
# GCI (booking.cgi): enregistrement d'une réunion
########################################################################

if [ "${is_editor}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à modifier une réunion"
fi

mail_tpl="${JMB_PATH}/inc/mail_tpl_edit.sh"
subject="$(utf8_to_mime ${JMB_SUBJECT_EDIT_OWNER})"

source ${JMB_PATH}/inc/register_data.sh
source ${JMB_PATH}/inc/register_sql_edit.sh
source ${JMB_PATH}/inc/mail_register.sh

########################################################################

# Envoyer le contenu HTML de la réservation
source ${JMB_PATH}/inc/page_register_edit.sh >> ${out}
http_200
