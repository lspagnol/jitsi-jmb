
echo "${guest}" | grep -q "${JMB_MAIL_DOMAIN//./\\.}$"
if [ ${?} -eq 0 ] ; then
cat<<EOT


Vous pouvez réserver vos visioconférences en suivant ce lien:
${JMB_SCHEME}://${SERVER_NAME}/booking.cgi
EOT
fi
