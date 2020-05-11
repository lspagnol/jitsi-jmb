#!/bin/bash

########################################################################
# GCI (booking.cgi): liste des réunions
########################################################################

# Fichier temporaire contenu HTML
out=${JMB_CGI_TMP}/http_${tsn}.message

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
source ${JMB_PATH}/inc/form_list.sh >> ${out}

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
