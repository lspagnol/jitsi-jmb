#!/bin/bash

########################################################################
# GCI (booking.cgi): création d'une réunion
########################################################################

isAllowed
if [ "${is_allowed}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à créer une réunion"
fi

tpl_mail_owner="${JMB_PATH}/inc/mail_new_owner.sh"
subject_mail_owner="${JMB_SUBJECT_NEW_OWNER}"

source ${JMB_PATH}/inc/register_data.sh
source ${JMB_PATH}/inc/mail_register.sh

########################################################################

# Envoyer le contenu HTML de la réservation
source ${JMB_PATH}/inc/page_register_new.sh >> ${out}
http_200
