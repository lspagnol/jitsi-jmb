# Jitsi Meet Booking (JMB)

## Fonctionnalités:

* Authentification universelle (CAS, Shibboleth, SAML, LDAP, ...)
* Réservation et planification des réunions
* Gestion des modérateurs et des invités
* Rappels par mail (début des réunions)
* Rappels via XMPP (fin des réunions)
* Flux iCal

## Présentation:

* **JMB** est un *POC* de réservation/planification de visioconférences *Jitsi Meet*:
  * **token.cgi** assure l'**authentification** via n'importe quel module d'authentification d'Apache,
  * **token.cgi** assure l'**autorisation** (activation des réunions) via les infos gérées par **booking.cgi**,
  * **booking.cgi** permet de gérer/planifier/réserver les visioconférences,
  * **ical.cgi** génère un flux iCal pour chaque utilisateur.
* **JMB** est modulaire: vous pouvez créer/ajouter vos propres modules de contrôle.
* *Les CGI en Bash, c'est moche, mais j'ai pas le temps de tout ré-écrire en Python ... avis aux volontaires ! ;)*

## Prérequis:

Le serveur *Jisti Meet* **DOIT** être installé, configuré et fonctionnel avec:

* *Nginx*
* L'authentification *JWT*

## Installation:

* Lancez le script d'installation et suivez les indications:

```
chmod +x install.sh
. /install.sh
```

* Si vous avez un logo, copiez-le dans */opt/jitsi-jmb/etc/logo.png* et décommentez les lignes correspondantes dans la configuration d'Apache.

## Work in progress ...
* Ajout reminders / mail pour les modérateurs
* Factorisation du code / templates mail
* Migrer le stockage des données: fichiers -> SQLite

## Divers:

* [Plugins Munin](https://github.com/lspagnol/jitsi-jmb/tree/master/munin)
* [Exemples de fichiers de configuration](https://github.com/lspagnol/jitsi-jmb/tree/master/conf-samples)

## Références:

* https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
* https://github.com/jitsi/jitsi-meet/wiki/jitsi-meet-with-Apache-on-Ubuntu-18.04-and-Shibboleth-Authentication
* https://github.com/jitsi/jicofo/blob/master/doc/reservation.md
* https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest.md
* https://github.com/jitsi/jitsi-videobridge/blob/master/doc/rest-colibri.md
* https://github.com/jitsi/jitsi-meet/blob/master/doc/turn.md
* https://community.jitsi.org/t/non-standard-characters-in-conference-room-name-request-result-in-404-error/18199/2
* https://doc.ubuntu-fr.org/prosody
