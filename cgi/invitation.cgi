#!/bin/bash

########################################################################
# CGI de gestion des invitations
########################################################################

# Timestamps
now=$(date +%s)
tsn=$(date +%s%N)

########################################################################

# Charger la configuration et les fonctions
JMB_PATH=/opt/jitsi-jmb
source ${JMB_PATH}/etc/jmb.cf
source ${JMB_PATH}/lib/jmb.lib

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

########################################################################

# Décodage et extraction des données GET ("id=" passé dans l'URL)
getdecode

########################################################################

set > ${JMB_DEBUG}
