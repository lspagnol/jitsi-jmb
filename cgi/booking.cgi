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
