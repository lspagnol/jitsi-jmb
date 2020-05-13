#!/bin/bash

cat<<EOT

** Installation de Jitsi Meet Booking (JMB) **

"JMB" est prévu pour fonctionner sur une instance Jitsi Meet installée
avec Apache et l'authentification Shibboleth. Il fonctionnera sans
problème sur une instance configurée en cluster (distribution des
réunions sur plusieurs videobridges).

Jitsi Meet et l'authentification Shibboleth DOIVENT être fonctionnels.

Le script d'installation ajoutera les paquets suivants:
- postfix
- mailutils
- recode
- pwgen
- ldap-utils 
- wget
- sendxmpp

EOT

if [ "${1}" != "-f" ] ; then
	read -p "Voulez-vous continuer ? o/N " r
	[ "${r}" = "o" ] || exit
fi

debs="postfix mailutils recode pwgen ldap-utils wget sendxmpp"
r=$(dpkg -l | grep ^ii |awk '{print $2}' |egrep "^(${debs// /|})$")
n1=$(echo ${debs} |wc -w)
n2=$(echo ${r} |wc -w)

if [ ${n1} -ne ${n2} ] ; then
	apt update
	apt -y upgrade
	apt -y install ${debs}
fi

# Ne pas modifier ces variables !!!
JMB_PATH=/opt/jitsi-jmb
JMB_DATA=/var/www/jitsi-jmb

# Installation des scripts
mkdir -p ${JMB_PATH}
for d in bin cgi lib check_modules etc inc ; do
	mkdir -p ${JMB_PATH}/${d}
	cp ${d}/* ${JMB_PATH}/${d}
done
[ -f ${JMB_PATH}/etc/jmb_local.cf ] || cp ${JMB_PATH}/etc/jmb_local.cf.dist ${JMB_PATH}/etc/jmb_local.cf
chown -R root:root ${JMB_PATH}
chmod +x ${JMB_PATH}/cgi/*
chmod +x ${JMB_PATH}/bin/*

# Création des répertoires utilisés par JMB
mkdir -p ${JMB_DATA}
chown root: ${JMB_DATA}
for d in tmp booking booking_archive mail_reminder xmpp_reminder ; do
	mkdir -p ${JMB_DATA}/${d}
	chown www-data: ${JMB_DATA}/${d}
done

# Configuration JMB/Apache -> accès aux CGIs
[ -f /etc/apache2/sites-enabled/jitsi-jmb.conf ] || ln -fs ${JMB_PATH}/etc/jmb-apache.conf /etc/apache2/sites-enabled/jitsi-jmb.conf
[ -f /etc/apache2/mods-enabled/cgid.load ] || a2enmod cgid
cat README-conf-Apache.md

# Configuration de Jicofo
grep -q '^org\.jitsi\.impl\.reservation\.rest\.BASE_URL=' /etc/jitsi/jicofo/sip-communicator.properties
if [ ${?} -ne 0 ] ; then
	echo "org.jitsi.impl.reservation.rest.BASE_URL=http://localhost" >> /etc/jitsi/jicofo/sip-communicator.properties
fi

# Configuration de sendxmpp
echo "username: anonymous" > /root/.sendxmpprc
chmod 600 /root/.sendxmpprc

# Page Logout Shibboleth
ln -fs /opt/jitsi-jmb/inc/localLogout_fr.html /etc/shibboleth/

# Planification archivage des réunions expirées
cat<<EOT>/etc/cron.d/jitsi-jmb
################################################################
# Planification Jitsi JMB

# Purge des réunions planifiées et expirées
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_prune

# Mise à jour de la liste des salons privés
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_private-rooms

# Envoi des rappels par mail (début réunions)
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_mail-reminder

# Envoi des notification XMPP (fin réunion)
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_xmpp-reminder

#
EOT
