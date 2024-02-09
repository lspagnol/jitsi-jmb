#!/bin/bash

########################################################################

# Ne pas modifier ces variables !!!

JMB_PATH=/opt/jitsi-jmb
JMB_DATA=/var/www/jitsi-jmb
DEBS="sqlite3 bc postfix mailutils ldap-utils recode pwgen rsync wget curl sendxmpp jq apache2 libapache2-mod-auth-cas"

########################################################################

# Jitsi-meet **DOIT** être installé
dpkg -l jitsi-meet-tokens 2>/dev/null |grep -q '^ii'
if [ $? -ne 0 ] ; then
	echo
	echo "ABANDON: 'jitsi-meet-tokens' n'est pas installé ..."
	echo "Consultez 'README-install_jitsi-meet-tokens.md' !"
	echo
	exit
fi

########################################################################

# Nom de l'instance Jitsi, il **DOIT** correspondre à celle configurée
# lors de l'installation de Jitsi-Meet
name=$(ls -1 /etc/jitsi/meet/*-config.js)
name=$(basename ${name})
JITSI_FQDN=${name%-config.js}

# On essaie de déduire le nom du serveur CAS ...
DOMAIN=${JITSI_FQDN#*.}
CAS_SERVER=cas.${DOMAIN}

# Et de déduire les URLs pour le module auth_cas d'Apache ...
CASLoginURL="https://${CAS_SERVER}/cas/login"
CASValidateURL="https://${CAS_SERVER}/cas/serviceValidate"
CASRootProxiedAs="https://${JITSI_FQDN}"

# Et de déduire la conf LDAP ...
DOMAIN_DC=$(echo "${DOMAIN}" |sed 's/^/dc=/g ; s/\./,dc=/g')
LDAP_BASE="ou=people,${DOMAIN_DC}"
LDAP_USER="cn=jitsi-jmb,${LDAP_BASE}"
LDAP_SERVER="ldap.${DOMAIN}"

########################################################################

# Préparation du fichier "install.cf" à partir des variables auto-configurées
if [ ! -f install.cf ] ; then
	DOMAIN="${DOMAIN}"\
	JITSI_FQDN="${JITSI_FQDN}"\
	LDAP_BASE="${LDAP_BASE}"\
	LDAP_USER="${LDAP_USER}"\
	LDAP_SERVER="${LDAP_SERVER}"\
	CASLoginURL="${CASLoginURL}"\
	CASValidateURL="${CASValidateURL}"\
	CASRootProxiedAs="${CASRootProxiedAs}"\
	envsubst < install.cf.dist > install.cf
fi

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

Le script d'installation est autoconfiguré avec les valeurs suivantes:

$(cat install.cf)

Si ces valeurs sont incorrectes, vous pouvez les modifier dans le fichier
"install.cf" avant de continuer l'installation.

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

# Conf JMB:
# Réglage du FQDN et domaine à partir des valeur présentes dans
# "install.cf"
if [ ! -f ${JMB_PATH}/etc/jmb_local.cf ] ; then
	cp ${JMB_PATH}/etc/jmb_local.cf.dist ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/##_JITSI_FQDN_##/${JITSI_FQDN}/g" ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/##_DOMAIN_##/${DOMAIN}/g" ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/##_LDAP_BASE_##/${LDAP_BASE}/g" ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/##_LDAP_USER_##/${LDAP_USER}/g" ${JMB_PATH}/etc/jmb_local.cf
	sed -i "s/##_LDAP_SERVER_##/${LDAP_SERVER}/g" ${JMB_PATH}/etc/jmb_local.cf
fi

# Stockage des données:
# Création des répertoires
mkdir -p ${JMB_DATA}
chown root: ${JMB_DATA}
for d in tmp data ; do
	mkdir -p ${JMB_DATA}/${d}
	chown www-data: ${JMB_DATA}/${d}
	chmod 750 ${JMB_DATA}/${d}
done

# Stockage des données:
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

########################################################################

# Conf Nginx:
# Ajout de la conf "reverse-proxy" pour joindre le serveur Apache
mkdir -p /etc/jitsi/meet/jaas
cp etc/jmb-nginx.conf  /etc/jitsi/meet/jaas

# Conf Apache:
# Apache écoute sur 127.0.0.1:81, il est utilisé pour exécuter les CGI
# et assurer l'authentification
# Il n'est joignable qu'au travers de Nginx
a2enmod cgid
a2dissite 000-default
if [ -f /etc/apache2/mods-enabled/auth_cas.conf ] ; then
	cp etc/jmb-apache-auth_cas.conf /etc/apache2/sites-available
	a2ensite jmb-apache-auth_cas
fi

# Conf Apache:
# Réglage du module d'authentification CAS
sed -i 's/^Listen 80.*/Listen 127.0.0.1:81/g' /etc/apache2/ports.conf
CASLoginURL="${CASLoginURL}" CASValidateURL="${CASValidateURL}" CASRootProxiedAs="${CASRootProxiedAs}" envsubst < etc/auth_cas.conf > /etc/apache2/mods-enabled/auth_cas.conf
service apache2 restart

########################################################################

# Conf JWT / JMB:
# Récupérer le credential depuis Prosody pour les CGI
egrep '^[[:space:]]*(app_id|app_secret)=' /etc/prosody/conf.d/${JITSI_FQDN}.cfg.lua\
 |sed 's/^.*app_id=/JMB_JWT_ISS=/g ; s/^.*app_secret=/JMB_JWT_SECRET=/g'\
 > /opt/jitsi-jmb/etc/jmb_jwt.cf

# Conf JWT / Prosody:
# Autoriser les jetons vides pour permettre aux invités de se connecter
# aux réunions actives
egrep -q '^[[:space:]]*allow_empty_token = true' /etc/prosody/conf.d/${JITSI_FQDN}.cfg.lua
if [ $? -ne 0 ] ; then
	sed -i '/[[:space:]]*app_secret=.*/aallow_empty_token = true' /etc/prosody/conf.d/${JITSI_FQDN}.cfg.lua 
fi

# Conf JWT / Prosody:
# Ajouter le domaine "guest" pour permettre aux invités de se connecter aux réunions actives
egrep -q "^VirtualHost \"guest\.${JITSI_FQDN//./\\.}\"" /etc/prosody/conf.d/${JITSI_FQDN}.cfg.lua
if [ $? -ne 0 ] ; then
cat<<EOT>>/etc/prosody/conf.d/${JITSI_FQDN}.cfg.lua

VirtualHost "guest.${JITSI_FQDN}"
     authentication = "anonymous"
     c2s_require_encryption = false

EOT
fi

# Conf JWT / Jicofo:
# Accès direct à la réunion si elle est déjà active, sinon affiche la
# page d'attente "Je suis l'hôte"
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.conference.enable-auto-owner false
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.enabled true
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.type JWT
hocon -f /etc/jitsi/jicofo/jicofo.conf set jicofo.authentication.login-url ${JITSI_FQDN}

# Conf JWT / client Jitsi:
# URL de redirection pour l'authentification si l'utilisateur demande
# l'accès à une réunion qui n'a pas encore commencé
sed -i "s/\/\/ tokenAuthUrl:.*/tokenAuthUrl: 'https:\/\/${JITSI_FQDN}\/token.cgi?room={room}',/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js
sed -i "s/\/\/ tokenAuthUrlAutoRedirect:.*/tokenAuthUrlAutoRedirect: false,/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js

# Client Jitsi:
# Ajouter le domaine anonyme pour permettre aux invités de se connecter
# aux réunions actives
sed -i "s/\/\/ anonymousdomain:.*/anonymousdomain: 'guest.${JITSI_FQDN}',/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js

# Client Jitsi:
# Corrections traductions
grep -q '"sessTerminatedReason":' /usr/share/jitsi-meet/lang/main-fr.json
if [ $? -ne 0 ] ; then
	sed -i '/"sessTerminated":.*/a"sessTerminatedReason": "La réunion est terminée",' /usr/share/jitsi-meet/lang/main-fr.json
fi

# Client Jitsi:
# Traduction noms par défaut (local/remote)
sed -i "s/\/\/ defaultLocalDisplayName:.*/defaultLocalDisplayName: 'Moi',/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js
sed -i "s/\/\/ defaultRemoteDisplayName:.*/defaultRemoteDisplayName: 'Inconnu',/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js

# Client Jitsi:
# Le nom du participant est obligatoire pour accéder à une réunion
sed -i "s/\/\/ requireDisplayName:.*/requireDisplayName: true,/g" /etc/jitsi/meet/${JITSI_FQDN}-config.js

# Client Jitsi:
# Activer la page "pre-join" (réglages avant d'accéder à la réunion)
grep -q '^[[:space:]]*prejoinConfig:' /etc/jitsi/meet/${JITSI_FQDN}-config.js
if [ $? -ne 0 ] ; then
	sed -i "/\/\/ Configs for prejoin page./aprejoinConfig: { enabled: true , }," /etc/jitsi/meet/${JITSI_FQDN}-config.js
fi

# JVB:
# Activer les stats pour la métrologie 
# curl -s -f -m 3 http://localhost:8080/metrics -H 'Accept: application/json' |jq .
# curl -s -f -m 3 --noproxy "*" http://127.0.0.1:8080/colibri/stats |jq .
hocon -f /etc/jitsi/videobridge/jvb.conf set videobridge.apis.rest.enabled true

# JVB:
# Activer le debug pour la métrologie (permet d'avoir les stats des conférences)
# curl -s -f -m 3 http://localhost:8080/debug -H 'Accept: application/json' |jq .
hocon -f /etc/jitsi/videobridge/jvb.conf set videobridge.rest.debug.enabled true

# A vérifier:
# https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md
# http://www.java2s.com/example/java-src/pkg/org/jitsi/videobridge/rest/handlerimpl-d31ce.html

# Shibbloleth (si installé):
# Page Logout Shibboleth
if [ -d /etc/shibboleth/ ] ; then
	ln -fs /opt/jitsi-jmb/inc/localLogout_fr.html /etc/shibboleth/
fi

# LDAP (si configuré)
# Corriger les droits d'accès au fichier qui stocke le MDP
if [ -f /etc/ldap/ldap.secret ] ; then
	chown root:www-data /etc/ldap/ldap.secret
	chmod 640 /etc/ldap/ldap.secret
fi

# Plugin Munin (si installé):
# Installation "jitsi_videobridge_" (plugin destiné aux noeuds JVB),
# Le plugin "jitsi_videobridge_summary_" est destiné uniquement au noeud
# principal d'un cluster Jitsi
dpkg -l munin-node 2>/dev/null >/dev/null
if [ $? -eq 0 ] ; then
	mkdir -p /usr/local/share/munin/
	cp munin/jitsi_videobridge_ /usr/local/share/munin/
	chmod +x /usr/local/share/munin/jitsi_videobridge_
	for m in network conferences participants reservations system ; do
		ln -fs /usr/local/share/munin/jitsi_videobridge_ /etc/munin/plugins/jitsi_videobridge_${m}
	done
	echo -e "[jitsi_videobridge_*]\nuser root" > /etc/munin/plugin-conf.d/jitsi-videobridge
	echo "env.DB /var/www/jitsi-jmb/data/jitsi-jmb.db" >> /etc/munin/plugin-conf.d/jitsi-videobridge
	service munin-node restart
fi

# Configuration de sendxmpp -> **FIXME**
#echo "username: anonymous" > /root/.sendxmpprc
#chmod 600 /root/.sendxmpprc

## Modules Prosody supplémentaires (déconnexion des utilisateurs fantômes) -> **FIXME**
## - Remplacer storage = "none" par storage = "memory" dans /etc/prosody/conf.d/FQDN.cfg.lua
## - ajouter "pinger" à la liste des modules activés dans /etc/prosody/prosody.cfg.lua
#chown -R root: lua
#cp lua/* /usr/lib/prosody/modules/

# Planification
cat<<EOT>/etc/cron.d/jitsi-jmb
########################################################################
# Planification Jitsi JMB
########################################################################

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

########################################################################

# Exécution modules d'install "privés" (pas synchronisés sur GitHub)
if [ -f PRIVATE/install.sh ] ; then
	source PRIVATE/install.sh
fi

########################################################################
# FIN !!!
########################################################################
cat<<EOT

** Installation de Jitsi Meet Booking (JMB) terminée !! **

* Pensez à enregistrer le mot de passe du compte de lecture LDAP dans
  "/etc/ldap/ldap.secret" puis à régler ses droits d'accès:
  echo -n "SuperMDPldap" > /etc/ldap/ldap.secret
  chown root:www-data /etc/ldap/ldap.secret
  chmod 640 /etc/ldap/ldap.secret

Vous pouvez redémarrer le serveur et vous connecter au service
-> https://${JITSI_FQDN}

EOT
