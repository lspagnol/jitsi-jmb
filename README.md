# Jitsi Meet Booking (JMB)

## Fonctionnalités:

* **Authentification universelle** JWT / modules d'authentication Apache
  * CAS, Shibboleth, SAML, LDAP, SQL, ...
* **Réservation et planification** des réunions
* Gestion des **invités**
* Gestion des **modérateurs**
* Un **modérateur peut être un utilisateur externe** (ne pouvant pas s'authentifier)
* **Rappels par mail** (début des réunions)
* **Rappels par XMPP** (fin des réunions)
* **Flux iCal** pour la synchronisation des agendas

<img src="screenshot1.png" alt="Screenshot1: liste des réunions" width="350"/><img src="screenshot2.png" alt="Screenshot2: édition d'une réunion" width="350"/>

## Historique:
**JBM** a été écrit en quelques jours au début du premier confinement de la crise Covid pour proposer une solution de visioconférence souveraine et peu coûteuse à nos utilisateurs.
L'idée de départ était de fournir un outil de planification simple à utiliser: seuls les utilisateurs authentifiés pouvaient planifier, démarrer et modérer les réunions.
L'authentification était assurée par Shibboleth et la planification par l'API de réservation de Jicofo.
**JMB** a intégré, dès le départ, un mécanisme de rappels par mail et un flux iCal pour la synchronisation des agendas.
Malheureusement, les développeurs de Jitsi ont supprimé le support de Shibboleth et modifié l'API de réservation.
**Jitsi Meet** évolue très rapidement, l'authentification par Shibboleth n'étant plus supportée, il était indispensable de modifier **JMB** pour passer à **JWT**.
Ces modifications exploitent le comportement de Jitsi (les utilisateurs authentifiés sont modérateurs, les utilisateurs non authentifiés ne le sont pas) pour contourner l'API de réservation.

**JMB** a donc été modifié en profondeur:
* Authentification **JWT** / modules auth Apache,
* le stockage des données passe d'une arborescence de fichiers plats à une base SQLite,
* ajout du rôle de *modérateur* (un modérateur n'étant pas nécessairement un utilisateur qui peut s'authentifier).

## Fonctionnement:
* Le GCI **booking.cgi**:
  * est **protégé par un module d'authentification Apache** (par défaut: *auth_cas*),
  * permet à un utilisateur authentifié de planifier des réunions et de modifier celles qu'il a créé,
  * affiche la liste des réunions planifiées (réunions créés par l'utilisateur et celles auxquelles il est invité en tant que participant ou modérateur),
  * permet d'accéder aux réunions planifiées
    * redirection via **token.cgi** pour les propriétaires,
    * redirection via **join.cgi** pour les participants ou modérateurs,
  * permet d'inviter des participants et/ou des modérateurs,
  * les participants et/ou des modérateurs peuvent être des *utilisateurs externes* (ne pouvant pas s'authentifier),
  * génère, pour une réunion donnée, un *hash individuel* pour chaque participants et/ou modérateur,
  * expédie un mail de notification à chaque participant.
* Le CGI **token.cgi**:
  * est **protégé par un module d'authentification Apache** (par défaut: *auth_cas*),
  * n'est invoqué que par le propriétaire d'une réunion,
  * génère un jeton **JWT** et l'ajoute en paramètre lors de la redirection vers *Jitsi*.
* Le CGI **join.cgi**:
  * n'est pas protégé par une authentification (chaque participant a un *hash individuel*),
  * est invoqué par les modérateurs et les invités,
    * **modérateurs**: il génère un jeton **JWT** et l'ajoute en paramètre lors de la redirection vers *Jitsi*,
    * **invités**: il redirige directement vers *Jitsi*.
* Le CGI **ical.cgi**:
  * n'est pas protégé par une authentification (chaque utilisateur a un *hash individuel*),
  * génère un flux iCal permettant de synchroniser des agendas (Thunderbird, Smartphone, Nextcloud, ...),
  * son utilisation est implicitement limitée aux utilisateurs qui peuvent accéder à **booking.cgi** (utilisateurs pouvant s'authentifier).
* *Les CGI en Bash, c'est moche, mais j'ai pas le temps de tout ré-écrire en Python ... avis aux volontaires ! ;)*

## Prérequis:

* Testé sur **Ubuntu 22.04**, *devrait fonctionner* sur **Debian 12**.
* Un compte permettant d'accéder à l'annuaire LDAP de votre organisation.
* Un SSO fonctionnel (par défaut: serveur **CAS**).
* Un MTA (Postfix) configuré pour relayer les mails.
* Le serveur *Jisti Meet* **DOIT** être installé, configuré et fonctionnel avec l'authentication JWT.
* -> voir [README-install_jitsi-meet-tokens.md](README-install_jitsi-meet-tokens.md)

## Installation:

* Lancez le script d'installation et suivez les indications puis redémarrez le serveur:

```
bash install.sh
reboot
```

* Si vous avez un logo, copiez-le dans */opt/jitsi-jmb/etc/logo.png*.

## TODO

* Adapter *jitsi-jmb_show* au stockage SQLite
* Corriger les rappels *xmpp*
* Générer et ajouter un contenu ICS aux notifications envoyés par mail
* ~~Ajout -r ${mailfrom} à la commande mail si l'organisateur n'est pas sur le domaine du serveur Jitsi (fixer l'expéditeur d'enveloppe pour passer les contrôles SPF)~~

## Divers:

* [Plugins Munin](https://github.com/lspagnol/jitsi-jmb/tree/master/munin)
* [Exemples de fichiers de configuration](https://github.com/lspagnol/jitsi-jmb/tree/master/conf-samples)

## Références:

* Paramètres Jicofo: https://github.com/jitsi/jicofo/blob/master/jicofo-selector/src/main/resources/reference.conf
* Paramètres JVB: https://github.com/jitsi/jitsi-videobridge/blob/master/jvb/src/main/resources/reference.conf
* Générateur d'URLs Jitsi: https://shawnchin.github.io/jitsi-url-generator/

## Références **FIXME** (probablement obsolètes):

* https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
* https://github.com/jitsi/jitsi-meet/wiki/jitsi-meet-with-Apache-on-Ubuntu-18.04-and-Shibboleth-Authentication
* https://github.com/jitsi/jicofo/blob/master/doc/reservation.md
* https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md
* https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest-colibri.md
* https://github.com/jitsi/jitsi-meet/blob/master/doc/turn.md
* https://community.jitsi.org/t/non-standard-characters-in-conference-room-name-request-result-in-404-error/18199/2
* https://doc.ubuntu-fr.org/prosody

