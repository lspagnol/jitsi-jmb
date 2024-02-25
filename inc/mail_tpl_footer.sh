########################################################################
# Template notification mail: footer
########################################################################

# On intègre la référence au service de réservation pour les
# destinataires qui peuvent s'authentifier
# -> membres de "${JMB_MAIL_DOMAIN}"

########################################################################
# Template notification mail: footer
########################################################################

# On intègre la référence au service de réservation pour les
# destinataires qui peuvent s'authentifier

unset hash

# Adresse mail connue dans l'annuaire LDAP ? -> on récupère l'uid correspondant
r=$($JMB_LDAPSEARCH "(|(mail=${mailto})(mailAlternateAddress=${mailto}))" uid |grep '^uid: ')
r=(${r}) ; r=${r[1]}

if [ "${r}" != "" ] ; then

	# on récupère le hash iCal correspondant
	hash=$(get_ical_hash ${r})

	cat<<EOT


* Vous pouvez gérer vos visioconférences en suivant ce lien:
https://${JMB_SERVER_NAME}/booking.cgi

* Synchronisez vos agendas (Thunderbird, Nextcloud, Smartphone, ...) avec le lien iCal suivant:
https://${JMB_SERVER_NAME}/ical.cgi?${hash}
EOT

fi
