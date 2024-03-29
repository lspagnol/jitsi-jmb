#!/bin/bash

########################################################################
# CGI de l'interface de réservation
########################################################################

# Timestamps
now=$(date +%s)
tsn=$(date +%s%N)

########################################################################

# Charger la configuration et les fonctions
JMB_PATH=/opt/jitsi-jmb
source ${JMB_PATH}/etc/jmb.cf
source ${JMB_PATH}/lib/jmb.lib

########################################################################

# Décodage et extraction des données POST et GET
postdecode
getdecode

# On positionne le cookie de l'interface de gestion
setcookie=1

# Récupérer les infos utilisateur à partir de l'authentification
source ${JMB_PATH}/modules/${JMB_MODULE_GET_AUTH_IDENTITY}

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_editor=0" -> non, "is_editor=1" -> oui
check_is_editor

########################################################################

case ${query} in

	list)
		source ${JMB_PATH}/lib/list.sh
	;;

	del)
		source ${JMB_PATH}/lib/del.sh
	;;

	new)
		source ${JMB_PATH}/lib/new.sh
	;;

	edit)
		source ${JMB_PATH}/lib/edit.sh
	;;

	attendees)
		source ${JMB_PATH}/lib/attendees.sh
	;;

	register_new)
		source ${JMB_PATH}/lib/register_new.sh
	;;

	register_edit)
		source ${JMB_PATH}/lib/register_edit.sh
	;;

	*)
		source ${JMB_PATH}/lib/list.sh
	;;

esac
