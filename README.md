# Jitsi Meet Booking (JMB)

## Mots clé:

* Planification
* Réservation
* Modération, modérateur
* Rappels par mail (début des réunions)
* Rappels via XMPP (fin des réunions)
* Booking, moderator, reminder

## Présentation:

* **JMB** est un *POC* de réservation/planification de visioconférences *Jitsi Meet*:
  * le **CGI** *conference.cgi*, appelé par *Jicofo*, assure le contrôle de la création et de la modération des visioconférences,
  * le **CGI** *booking.cgi* permet de planifier/réserver les visioconférences.
* **JMB** est modulaire: vous pouvez créer/ajouter vos propres modules de contrôle.
* **JMB** s'appuie sur l'API Rest de Jicofo.

## Prérequis:

Le serveur *Jisti Meet* **DOIT** être installé, configuré et fonctionnel avec:

* *Apache*
* L'authentification *Shibboleth*

## Installation:

* Lancez le script d'installation et suivez les indications:

```
chmod +x install.sh
. /install.sh
```
* Si vous avez un logo, copiez-le dans */opt/jitsi-jmb/etc/logo.png* et décommentez les lignes correspondantes dans la configuration d'Apache.

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
