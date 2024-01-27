########################################################################
# Notification mail: footer -> invités
########################################################################

echo "${guest}" | grep -q "${JMB_MAIL_DOMAIN//./\\.}$"
if [ ${?} -eq 0 ] ; then
cat<<EOT


Vous pouvez gérer vos visioconférences en suivant ce lien:
${JMB_SCHEME}://${JMB_SERVER_NAME}/booking.cgi
EOT
fi
