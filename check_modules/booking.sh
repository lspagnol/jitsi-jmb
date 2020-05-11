#!/bin/bash

########################################################################
# Conférences planifiées
########################################################################

# Si la réunion est planifiée, s'assurer qu'elle n'est pas expirée et
# que la demande d'activation est faite par son propriétaire.

grep -H "^name=${name}$" ${JMB_BOOKING_DATA}/* 2>/dev/null |cut -d: -f1 > ${JMB_CGI_TMP}/${tsn}.booking
if [ ${PIPESTATUS[0]} = 0 ] ; then

	# La conférence est planifiée

	r=$(cat ${JMB_CGI_TMP}/${tsn}.booking)
	rm ${JMB_CGI_TMP}/${tsn}.booking

	# Elle est expirée par défaut
	expired=1

	# On recherche une période non expirée dans
	# la liste des réservations
	for f in ${r} ; do
	        unset begin duration end
	        eval $(egrep "^(begin|duration)=" ${f})
	        end=$(( ${begin} + ${duration} ))
	        if [ ${now} -lt ${end} ] ; then
			# On a trouvé une réservation non expirée
	                expired=0
	                c=${f}
                	# On corrige la durée de la réunion
					duration=$(( ${duration} + ${begin} - ${now} ))
	                break
	        fi
	done

	if [ ${expired} = 1 ] ; then
        	http_403_json "la date de la conférence '${name}' est expirée"
	fi

	grep -q "^mail_owner=${mail_owner}$" ${c}
	if [ ${?} -ne 0 ] ; then
        	http_403_json "vous n'êtes pas le modérateur de la conférence '${name}'"
	fi

fi

rm ${JMB_CGI_TMP}/${tsn}.booking
