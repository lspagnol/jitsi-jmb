#!/bin/bash

########################################################################

# Ne pas modifier ces variables !!!

JMB_PATH=/opt/jitsi-jmb
JMB_DATA=/var/www/jitsi-jmb
DEBS="sqlite3 bc postfix mailutils ldap-utils recode pwgen wget curl sendxmpp jq apache2 libapache2-mod-auth-cas"

########################################################################

dpkg -l jitsi-meet-tokens 2>/dev/null |grep -q '^ii'
if [ $? -ne 0 ] ; then
	echo
	echo "ABANDON: 'jitsi-meet-tokens' n'est pas installé ..."
	echo "Consultez 'README-install_jitsi-meet-tokens.md' !"
	echo
	exit
fi

if [ ! -f install.cf ] ; then
	cp install.cf.dist install.cf
fi

# Nom de l'instance Jitsi, il **DOIT** correspondre à celle configurée
# lors de l'installation de Jitsi-Meet
name=$(ls -1 /etc/jitsi/meet/*-config.js)
name=$(basename ${name})
JITSI_NAME=${name%-config.js}

# On essaie de déduire le nom du serveur CAS ...
DOMAIN=${JITSI_NAME#*.}
CAS_SERVER=cas.${DOMAIN}

# Et de déduire les URLs pour le module auth_cas d'Apache ...
CASLoginURL="https://${CAS_SERVER}/cas/login"
CASValidateURL="https://${CAS_SERVER}/cas/serviceValidate"
CASRootProxiedAs="https://${JITSI_NAME}"

# On charge le fichier de conf/install pour écraser les variables
# prédéfinies si nécessaire
source install.cf

########################################################################

cat<<EOT

** Installation de Jitsi Meet Booking (JMB) **

"JMB" est prévu pour fonctionner sur une instance Jitsi Meet fraichement
installée et configurée avec l'authentification JWT.

La configuration par défaut de Nginx ne sera pas modifiée.
L'authentification et l'exécution des CGI sera assurée par Apache qui
sera insallé et configuré automatiquement avec l'authentification CAS.

JMB fonctionnera sans problème sur une instance configurée en cluster
(distribution des réunions sur plusieurs videobridges).

Le script d'installation ajoutera les paquets suivants:
${DEBS}

Le script d'installation s'est autoconfiguré avec les valeurs suivantes:

JITSI_NAME="${JITSI_NAME}"
CAS_SERVER="${CAS_SERVER}"
CASLoginURL="${CASLoginURL}"
CASValidateURL="${CASValidateURL}"
CASRootProxiedAs="${CASRootProxiedAs}"

Si ces valeurs sont incorrectes, vous pouvez les définir dans le fichier
"install.cf".

EOT

if [ "${1}" != "-f" ] ; then
	read -p "Voulez-vous continuer ? o/N " r
	[ "${r}" = "o" ] || exit
fi

########################################################################

# Vérification / installation paquets
r=$(dpkg -l | grep ^ii |awk '{print $2}' |egrep "^(${DEBS// /|})$")
n1=$(echo ${DEBS} |wc -w)
n2=$(echo ${r} |wc -w)
if [ ${n1} -ne ${n2} ] ; then
	apt update
	apt -y upgrade
	apt -y install ${DEBS}
fi

# Installation des scripts
mkdir -p ${JMB_PATH}
for d in bin cgi lib modules etc inc ; do
	mkdir -p ${JMB_PATH}/${d}
	cp ${d}/* ${JMB_PATH}/${d}
done
chown -R root:root ${JMB_PATH}
chmod +x ${JMB_PATH}/cgi/*
chmod +x ${JMB_PATH}/bin/*
ln -fs ${JMB_PATH}/bin/jitsi-jmb_show /usr/local/bin
ln -fs ${JMB_PATH}/bin/jitsi-restart /usr/local/sbin

# Conf JMB
if [ ! -f ${JMB_PATH}/etc/jmb_local.cf ] ; then
	cp ${JMB_PATH}/etc/jmb_local.cf.dist ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/^#JMB_SERVER_NAME=.*/JMB_SERVER_NAME=\"${JITSI_NAME}\"/g" ${JMB_PATH}/etc/jmb_local.cf
fi

# Création des répertoires utilisés par JMB
mkdir -p ${JMB_DATA}
chown root: ${JMB_DATA}
for d in tmp data ; do
	mkdir -p ${JMB_DATA}/${d}
	chown www-data: ${JMB_DATA}/${d}
	chmod 750 ${JMB_DATA}/${d}
done

# Initialisation de la base SQLite
if [ ! -f ${JMB_DATA}/data/jitsi-jmb.db ] ; then

	cat schema_sqlite.sql |sqlite3 ${JMB_DATA}/data/jitsi-jmb.db
	chown www-data: ${JMB_DATA}/data/jitsi-jmb.db
	chmod 660 ${JMB_DATA}/data/jitsi-jmb.db

	# Importation des donnés présentes (fichiers plats) dans la base SQLite
	if [ -d ${JMB_DATA}/booking ] ; then
		bash migrate2sqlite.sh
		rm -rf ${JMB_DATA}/booking/ ${JMB_DATA}/booking_archive/ ${JMB_DATA}/ical/ ${JMB_DATA}/mail_reminder/ ${JMB_DATA}/xmpp_reminder/
	fi

fi

# Conf JMB / Nginx:
# Ajout de la conf qui permet de joindre Apache pour les CGI l'authentification
mkdir -p /etc/jitsi/meet/jaas
cp etc/jmb-nginx.conf  /etc/jitsi/meet/jaas

# Conf JMB / Apache:
# Apache est utilisé pour exécuter les CGI et assurer l'authentification
# et n'est joignable qu'au travers du frontal / Nginx
a2enmod cgid
a2dissite 000-default
if [ -f /etc/apache2/mods-enabled/auth_cas.conf ] ; then
	cp etc/jmb-apache-auth_cas.conf /etc/apache2/sites-available
	a2ensite jmb-apache-auth_cas
fi
sed -i 's/^Listen 80.*/Listen 127.0.0.1:81/g' /etc/apache2/ports.conf
CASLoginURL="${CASLoginURL}" CASValidateURL="${CASValidateURL}" CASRootProxiedAs="${CASRootProxiedAs}" envsubst < etc/auth_cas.conf > /etc/apache2/mods-enabled/auth_cas.conf
service apache2 restart

# Conf JWT / JMB: récupérer le credential depuis Prosody pour les CGI
egrep '^[[:space:]]*(app_id|app_secret)=' /etc/prosody/conf.d/${JITSI_NAME}.cfg.lua\
 |sed 's/^.*app_id=/JMB_JWT_ISS=/g ; s/^.*app_secret=/JMB_JWT_SECRET=/g'\
 > /opt/jitsi-jmb/etc/jmb_jwt.cf

# Conf JWT / Prosody: autoriser les jetons vides pour permettre aux
# invités de se connecter aux réunions actives
egrep -q '^[[:space:]]*allow_empty_token = true' /etc/prosody/conf.d/${JITSI_NAME}.cfg.lua
if [ $? -ne 0 ] ; then
	sed -i '/[[:space:]]*app_secret=.*/aallow_empty_token = true' /etc/prosody/conf.d/${JITSI_NAME}.cfg.lua 
fi

# Conf JWT / Prosody: ajouter le domaine "guest" pour permettre aux
# invités de se connecter aux réunions actives
egrep -q "^VirtualHost \"guest\.${JITSI_NAME//./\\.}\"" /etc/prosody/conf.d/${JITSI_NAME}.cfg.lua
if [ $? -ne 0 ] ; then
cat<<EOT>>/etc/prosody/conf.d/${JITSI_NAME}.cfg.lua

VirtualHost "guest.${JITSI_NAME}"
     authentication = "anonymous"
     c2s_require_encryption = false

EOT
fi

# Conf JWT / Jicofo:
# accès à une réunion possible uniquement si elle est déjà active ou si
# le participant est authentifié
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.conference.enable-auto-owner false
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.enabled true
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.type JWT
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.login-url ${JITSI_NAME}

# Conf JWT / client Jitsi: URL de redirection si l'authentification est demandée
sed -i "s/\/\/ tokenAuthUrl:.*/tokenAuthUrl: 'https:\/\/${JITSI_NAME}\/token.cgi?room={room}',/g" /etc/jitsi/meet/${JITSI_NAME}-config.js
sed -i "s/\/\/ tokenAuthUrlAutoRedirect:.*/tokenAuthUrlAutoRedirect: false,/g" /etc/jitsi/meet/${JITSI_NAME}-config.js

# Client Jitsi: ajouter le domaine anonyme pour permettre aux invités
# de se connecter aux réunions actives
sed -i "s/\/\/ anonymousdomain:.*/anonymousdomain: 'guest.${JITSI_NAME}',/g" /etc/jitsi/meet/${JITSI_NAME}-config.js

# Client Jitsi: correction traduction
grep -q '"sessTerminatedReason":' /usr/share/jitsi-meet/lang/main-fr.json
if [ $? -ne 0 ] ; then
	sed -i '/"sessTerminated":.*/a"sessTerminatedReason": "La réunion est terminée",' /usr/share/jitsi-meet/lang/main-fr.json
fi

# Client Jitsi: le nom du participant est obligatoire
sed -i "s/\/\/ requireDisplayName:.*/requireDisplayName: true,/g" /etc/jitsi/meet/${JITSI_NAME}-config.js

# Client Jitsi: traduction noms par défaut (local/remote)
sed -i "s/\/\/ defaultLocalDisplayName:.*/defaultLocalDisplayName: 'Moi',/g" /etc/jitsi/meet/${JITSI_NAME}-config.js
sed -i "s/\/\/ defaultRemoteDisplayName:.*/defaultRemoteDisplayName: 'Inconnu',/g" /etc/jitsi/meet/${JITSI_NAME}-config.js

# Client Jitsi: page "pre-join" activée (réglages avant d'accéder à la réunion)
grep -q '^[[:space:]]*prejoinConfig:' /etc/jitsi/meet/${JITSI_NAME}-config.js
if [ $? -ne 0 ] ; then
	sed -i "/\/\/ Configs for prejoin page./aprejoinConfig: { enabled: true , }," /etc/jitsi/meet/${JITSI_NAME}-config.js
fi

# JVB: activer les stats pour la métrologie 
# curl -s -f -m 3 http://localhost:8080/metrics -H 'Accept: application/json' |jq .
# curl -s -f -m 3 --noproxy "*" http://127.0.0.1:8080/colibri/stats |jq .
hocon -f /etc/jitsi/videobridge/jvb.conf set videobridge.apis.rest.enabled true

# JVB: activer le debug pour la métrologie (permet d'avoir les stats des conférences)
# curl -s -f -m 3 http://localhost:8080/debug -H 'Accept: application/json' |jq .
hocon -f /etc/jitsi/videobridge/jvb.conf set videobridge.rest.debug.enabled true

# A vérifier:
# https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md
# http://www.java2s.com/example/java-src/pkg/org/jitsi/videobridge/rest/handlerimpl-d31ce.html

# Page Logout Shibboleth (si installé)
if [ -d /etc/shibboleth/ ] ; then
	ln -fs /opt/jitsi-jmb/inc/localLogout_fr.html /etc/shibboleth/
fi

# MDP LDAP si configuré -> corriger les droits
if [ -f /etc/ldap/ldap.secret ] ; then
	chown root:www-data /etc/ldap/ldap.secret
	chmod 640 /etc/ldap/ldap.secret
fi

# Plugins Munin:
# Seulement si "/usr/local/share/munin/" existe (pour MAJ)
if [ -d /usr/local/share/munin/ ] ; then
	cp munin/* /usr/local/share/munin/
fi

# Configuration de sendxmpp -> **FIXME**
#echo "username: anonymous" > /root/.sendxmpprc
#chmod 600 /root/.sendxmpprc

## Modules Prosody supplémentaires (déconnexion des utilisateurs fantômes) -> **FIXME**
## - Remplacer storage = "none" par storage = "memory" dans /etc/prosody/conf.d/FQDN.cfg.lua
## - ajouter "pinger" à la liste des modules activés dans /etc/prosody/prosody.cfg.lua
#chown -R root: lua
#cp lua/* /usr/lib/prosody/modules/

cp ${JMB_PATH}/etc/jmb_URCA.cf ${JMB_PATH}/etc/jmb_local.cf

# Planification
cat<<EOT>/etc/cron.d/jitsi-jmb
################################################################
# Planification Jitsi JMB

# Purge des réunions planifiées et expirées -> **FIXME** (obsolète -> DB / SQLite)
#*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_prune

# Mise à jour de la liste des salons privés
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_private-rooms

# Envoi des rappels par mail (début réunion)
*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_mail-reminder

# Envoi des notification XMPP (fin réunion) -> **FIXME** (sendxmpp ne fonctionne plus avec Prosody)
#*/5 * * * * root /opt/jitsi-jmb/bin/jitsi-jmb_xmpp-reminder

#
EOT

# FIN !!!

cat<<EOT

** Installation de Jitsi Meet Booking (JMB) terminée !! **

Vous pouvez redémarrer le serveur et vous connecter au service
-> https://${JITSI_NAME}

EOT
