#!/bin/bash

########################################################################
# GCI (booking.cgi): création d'une réunion
########################################################################

# Générer un nom de réunion aléatoire
conf_name=$(${JMB_GEN_NAME})

# Arrondir la date de début au 1/4 d'heure suivant la date actuelle
now=$(( ${now} / 60 / 15 ))
now=$(( ( ${now} * 60 * 15 ) + 900 ))

# Générer date et heure pour le formulaire
conf_date=$(date -d @${now} +%Y-%m-%d)
conf_time=$(date -d @${now} +%R)

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

###################################################################

# Contenus

# Debut HTML
cat<<EOT > ${out}
<HTML><HEAD>
<TITLE>${JMB_NAME}</TITLE>
EOT

# Insertion du CSS
cat ${JMB_PATH}/inc/jmb.css >> ${out}

# Debut corps
cat<<EOT >> ${out}
</HEAD>
<BODY>
EOT

# Insertion du formulaire
source ${JMB_PATH}/inc/form_new.sh >> ${out}

# Fin corps
cat<<EOT >> ${out}
</BODY>
EOT

# Fin HTML
cat<<EOT >> ${out}
</HTML>
EOT

# Envoyer le résultat
http_200
