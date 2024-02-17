########################################################################
# Template notification mail: footer
########################################################################

# On intègre la référence au service de réservation pour les
# destinataires qui peuvent s'authentifier
# -> membres de "${JMB_MAIL_DOMAIN}"

echo "${mailto}" | grep -q "${JMB_MAIL_DOMAIN//./\\.}$"
if [ ${?} -eq 0 ] ; then
cat<<EOT


Vous pouvez gérer vos visioconférences en suivant ce lien:
https://${JMB_SERVER_NAME}/booking.cgi
EOT
fi
