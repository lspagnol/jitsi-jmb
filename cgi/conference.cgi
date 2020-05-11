#!/bin/bash

########################################################################
# CGI appelé par Jicofo -> autorisation pour l'activation des réunions
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

# Décodage et extraction des données POST
postdecode

# Durée par défaut des conférences
duration=${JMB_DEFAULT_DURATION}

########################################################################

# Modules de vérification
for check_module in ${JMB_CHECK_MODULES} ; do
	[ -f ${JMB_PATH}/check_modules/${check_module}.cf ] && source ${JMB_PATH}/check_modules/${check_module}.cf
	[ -f ${JMB_PATH}/check_modules/${check_module}.sh ] && source ${JMB_PATH}/check_modules/${check_module}.sh
done

########################################################################

# Toutes les vérifications sont OK
http_200_json
