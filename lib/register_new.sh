#!/bin/bash

########################################################################
# GCI (booking.cgi): création d'une réunion
########################################################################

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_allowed=0" -> non, "is_allowed=1" -> oui
set_is_allowed
if [ "${is_allowed}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à créer une réunion"
fi

mail_tpl="${JMB_PATH}/inc/mail_tpl_new.sh"
subject="$(utf8_to_mime ${JMB_SUBJECT_NEW_OWNER})"

source ${JMB_PATH}/inc/register_data.sh
source ${JMB_PATH}/inc/register_sql_new.sh
source ${JMB_PATH}/inc/mail_register.sh

########################################################################

# Envoyer le contenu HTML de la réservation
source ${JMB_PATH}/inc/page_register_new.sh >> ${out}
http_200
