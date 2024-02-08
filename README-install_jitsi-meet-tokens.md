# Installation de Jitsi Meet + tokens JWT

Configuration de jitsi-videobridge2
The domain of the current installation (e.g. meet.jitsi.com):
-> FQDN du service (en principe, celui du serveur hôte)

Configuration de jitsi-meet-tokens
The application ID to be used by token authentication plugin:
-> jitsi-auth

Configuration de jitsi-meet-tokens
The application secret to be used by token authentication plugin:
-> un mot de passe aléatoire (example: 'pwgen 32 1' -> Keimeicie3yeihaiG4hihevob8Ooshei)

Configuration de jitsi-meet-web-config
SSL certificate
-> au choix (certificat signé type *Let's Encrypt* recommandé)

Configuration de jitsi-meet-web-config
Add telephony to your Jitsi meetings?
-> Non

Redémarrer le serveur
