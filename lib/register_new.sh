#!/bin/bash

########################################################################
# GCI (booking.cgi): création d'une réunion
########################################################################

tpl_mail_owner="${JMB_PATH}/inc/mail_new_owner.sh"
subject_mail_owner="${JMB_SUBJECT_NEW_OWNER}"

tpl_mail_guest="${JMB_PATH}/inc/mail_new_guest.sh"
subject_mail_guest="${JMB_SUBJECT_NEW_GUEST}"

source ${JMB_PATH}/lib/register.sh
source ${JMB_PATH}/lib/mail.sh

########################################################################

# Envoyer le contenu HTML de la réservation
source ${JMB_PATH}/inc/form_register_new.sh >> ${out}
http_200
