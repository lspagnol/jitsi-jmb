#!/bin/bash

########################################################################
# GCI (booking.cgi): enregistrement d'une réunion
########################################################################

tpl_mail_owner="${JMB_PATH}/inc/mail_edit_owner.sh"
subject_mail_owner="${JMB_SUBJECT_EDIT_OWNER}"

tpl_mail_guest="${JMB_PATH}/inc/mail_edit_guest.sh"
subject_mail_guest="${JMB_SUBJECT_EDIT_GUEST}"

source ${JMB_PATH}/lib/register.sh
source ${JMB_PATH}/lib/mail.sh

########################################################################

# Envoyer le contenu HTML de la réservation
source ${JMB_PATH}/inc/form_register_edit.sh >> ${out}
http_200
