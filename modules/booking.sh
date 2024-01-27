#!/bin/bash

########################################################################
# Réunions planifiées
########################################################################

# Si la réunion est planifiée, s'assurer qu'elle n'est pas expirée et
# que la demande d'activation est faite par son propriétaire.

grep -H "^name=${room}$" ${JMB_BOOKING_DATA}/* 2>/dev/null |cut -d: -f1 > ${JMB_CGI_TMP}/${tsn}.booking
if [ ${PIPESTATUS[0]} = 0 ] ; then

	# La réunion est planifiée

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
        	http_403 "La date de la réunion '${room}' est expirée"
	fi

	grep -q "^owner=${auth_mail}$" ${c}
	if [ ${?} -ne 0 ] ; then
		# L'utilisateur n'est pas le propriétaire de la réunion
		# On vérifie s'il est déclaré en tant que modérateur
		eval $(egrep "^moderators=" ${c})
		echo " ${moderators} " |grep -q " ${auth_mail} "
		if [ ${?} -ne 0 ] ; then
			http_403 "Vous n'êtes pas modérateur de la réunion '${room}'"
		fi
	fi

fi

rm ${JMB_CGI_TMP}/${tsn}.booking
