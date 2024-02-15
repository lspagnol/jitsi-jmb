#!/bin/bash

########################################################################
# GCI (booking.cgi): modification d'une réunion
########################################################################

# Vérifier si l'utilisateur est autorisé à créer/editer une réunion
# Résultat: variable "is_editor=0" -> non, "is_editor=1" -> oui
set_is_editor

if [ "${is_editor}" = "0" ] ; then
	http_403 "Vous n'êtes pas autorisé à modifier une réunion"
fi

# Le timestamp est l'ID de réunion
tsn=${id}

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

# Récupérer les données
get_meeting_infos ${tsn}

if [ "${owner}" != "${auth_mail}" ] ; then
	http_403 "Vous n'etes pas le propriétaire de cette réunion"
fi

conf_name=${name}
conf_object=$(utf8_to_html "${object}")
conf_date=$(date -d@${begin} +%Y-%m-%d)
conf_time=$(date -d@${begin} +%H:%M)
conf_duration=$(( ${duration} / 60 ))
conf_moderators=$(echo ${moderators} |sed 's/ /\n/g')
conf_guests=$(echo ${guests} |sed 's/ /\n/g')
conf_min_date=$(date -d@${now} +%Y-%m-%d)

old_conf_date="${conf_date}"
old_conf_time="${conf_time}"
old_conf_moderators="${conf_moderators}"
old_conf_guests="${conf_guests}"

########################################################################

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
source ${JMB_PATH}/inc/form_edit.sh >> ${out}

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
