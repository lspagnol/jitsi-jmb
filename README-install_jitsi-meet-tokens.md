# Installation de Jitsi Meet + tokens JWT

  * *Jitsi Meet* **DOIT** être installé et configuré conrrectement **AVANT** *Jitsi-JMB*:
    * certificat électronique (-> *Let's Encrypt* ou autre certificat signé),
    * support des jetons **JWT**

  * Si *Jitsi Meet* est déjà installé, nous recommandons de le désinstaller totalement au préalable puis de redémarrer le serveur:
```
rsync -a --delete /etc/ /etc.orig/
apt remove --purge $(dpkg -l |egrep "jitsi|jicofo|prosody|lua|nginx|apache|supervisor|nginx|turn|xmpp|openjdk|shibb" |awk '{print $2}')
apt autoremove --purge
rm -rf /etc/apache2 /etc/nginx /etc/jitsi /etc/prosody /usr/lib/nginx/ /usr/share/nginx/ /var/lib/apache2 /usr/local/lib/nginx/ /var/lib/prosody /etc/prosody /etc/shibboleth/
apt update
apt upgrade
reboot
```

  * Installer et configurer le MTA **Postfix**:
```
apt install postfix
```

  * L'installation de *jitsi-meet-tokens* **DOIT** être effectuée en même temps que les autres paquets pour que toutes les dépendances soient satisfaites:
```
mkdir -p /etc/apt/keyrings/

echo "deb [signed-by=/etc/apt/keyrings/prosody-debian-packages.key] http://packages.prosody.im/debian $(lsb_release -c -s) main" > /etc/apt/sources.list.d/prosody-debian-packages.list
curl -fsSL https://prosody.im/files/prosody-debian-packages.key -o /etc/apt/keyrings/prosody-debian-packages.key

echo "deb [signed-by=/etc/apt/keyrings/jitsi-key.gpg.key] https://download.jitsi.org stable/" > /etc/apt/sources.list.d/jitsi-stable.list
curl -fsSL https://download.jitsi.org/jitsi-key.gpg.key -o /etc/apt/keyrings/jitsi-key.gpg.key

apt update

apt install lua5.2 liblua5.2-dev jitsi-meet jicofo jitsi-meet-prosody jitsi-meet-tokens jitsi-meet-turnserver jitsi-meet-web jitsi-meet-web-config ldap-utils
reboot
```

  * `Configuration de jitsi-videobridge2`
    * `The domain of the current installation (e.g. meet.jitsi.com):`
    * -> **FQDN du service** (en principe, celui du serveur hôte)

  * `Configuration de jitsi-meet-tokens`
    * `The application ID to be used by token authentication plugin:`
    * -> **jitsi-auth**

  * `Configuration de jitsi-meet-tokens`
    * `The application secret to be used by token authentication plugin:`
    * -> **mot de passe aléatoire** (example: 'pwgen 32 1' -> Keimeicie3yeihaiG4hihevob8Ooshei)

  * `Configuration de jitsi-meet-web-config`
    * `SSL certificate`
    * -> **certificat signé** (*Let's Encrypt* recommandé)

  * `Configuration de jitsi-meet-web-config`
    * `Add telephony to your Jitsi meetings?`
    * -> **Non**

  * **Redémarrer le serveur**
