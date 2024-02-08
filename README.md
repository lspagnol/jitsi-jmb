# Jitsi Meet Booking (JMB)

## Fonctionnalités:

* Authentification JWT universelle / modules auth Apache (CAS, Shibboleth, SAML, LDAP, SQL, ...)
* Réservation et planification des réunions
* Gestion des invités
* Gestion des modérateurs
* Un modérateur peut être un utilisateur *externe* (ne pouvant pas s'authentifier)
* Rappels par mail (début des réunions)
* ~~Rappels via XMPP (fin des réunions)~~
* Flux iCal

## Présentation:

* **JMB** est un *POC* de réservation/planification pour les visioconférences *Jitsi Meet*:
  * **booking.cgi** permet de gérer/planifier/réserver les visioconférences,
  * **token.cgi** assure l'**authentification** JWT, il est *protégé* par un module d'authentification d'Apache (Shibboleth, SAML/auth_mellon, CAS, LDAP, SQL, ...)
  * **token.cgi** assure l'**autorisation** (activation des réunions) via les infos gérées par **booking.cgi**,
  * **join.cgi** assure le lien avec les URLs de réunions pour les modérateurs et les invités
  * **ical.cgi** génère un flux iCal pour chaque utilisateur.
* **JMB** est modulaire: vous pouvez créer/ajouter vos propres modules de contrôle.
* *Les CGI en Bash, c'est moche, mais j'ai pas le temps de tout ré-écrire en Python ... avis aux volontaires ! ;)*

## Historique:
**JBM** a été écrit en quelques jours au début du premier confinement de la crise Covid pour proposer une solution de visioconférence souveraine et peu coûteuse à nos utilisateurs.
L'idée de départ était de fournir un outil de planification simple à utiliser: seuls les utilisateurs authentifiés pouvaient planifier, démarrer et modérer les réunions.
L'authentification était assurée par Shibboleth et la planification par l'API de réservation de Jicofo.
JMB a intégré, dès le départ, un mécanisme de rappels par mail d'abonnement à un agenda par flux iCal.
Malheureusement, les développeurs de Jitsi ont supprimé le support de Shibboleth et (ce qui est probablement lié) l'API de réservation a été migrée de Jicofo à Prosody (ce qui la rend inutilisable).
**Jitsi Meet** évolue très rapidement, l'authentification par Shibboleth n'étant plus supportée, il était indispensable de modifier **JMB** pour passer à **JWT**.

**JMB** a donc été modifié en profondeur:
  * Authentification **JWT** / modules auth Apache,
  * le stockage des données passe d'une arborescence de fichiers plats à une base SQLite,
  * ajout du rôle de *modérateur* (un modérateur n'est pas nécessairement un utilisateur qui peut s'authentifier !).

## Prérequis:

  * Le serveur *Jisti Meet* **DOIT** être installé, configuré et fonctionnel avec l'authentication JWT.

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
