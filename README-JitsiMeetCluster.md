# Jitsi Meet Cluster

**Mots clé:**

* Equilibrage de charge, load balancing
* Haute disponibilité, high availability

**Notes:**

* Le cluster a été installé sous Ubuntu 18.04 LTS, la procédure est applicable sous Debian.

## Principe

* Un serveur *Jitsi Meet* (**JMS**) assure la signalisation et l'accueil des clients Web.
* Il distribue les conférences/réunions sur les *videobridges* (**JVB**).

### Schéma

```
               Client1   Client2   Client3   Client4
                  |         |         |         |
                  |         |         |         |
                  +---------+----+----+---------+
                                 |
                                 |
                                 |
             +-------------------+---------------------+
             |                                         |
             |                                         |
             v                                         |
       80, 443 TCP                                     v
          *JMS*                                    10000 UDP
     +--------------+                                *JVBs*
     |  Apache      |                       +---------------------+
     |  jitsi-meet  |    5222, 5347 TCP     |                     |
     |  prosody     |<---------+------------|  jitsi-videobridge  |
     |  jicofo      |          |            |                     |
     +--------------+          |            +---------------------+
                               |
                               |            +---------------------+
                               |            |                     |
                               +-----------+|  jitsi-videobridge  |
                               |            |                     |
                               |            +---------------------+
                               |
                               |            +---------------------+
                               |            |                     |
                               +-----------+|  jitsi-videobridge  |
                                            |                     |
                                            +---------------------+
```

## Procédure:

* **Installer et configurer le premier serveur (JMS).**

Pour facilier la mise au point, notamment sur la partie authentification Shibboleth, le **JMS** assurera aussi provisoirement le rôle de **JVB**.

Les ports **tcp/80**, **tcp/443** et **upd/10000** doivent donc être ouverts vers cette machine. Par défaut, *Jitsi Meet* installe le serveur Web *Nginx*, mais il détectera et configurera automatiquement la présence d'un serveur préalablement installé (*Nginx* ou *Apache*).

La prise en charge de *Shibboleth* étant plus simple avec *Apache*, il est recommandé d'installer *Apache* AVANT *Jitsi Meet*. L'étape suivante consiste à installer un certificat signé. Le script *install-letsencrypt-cert.sh* assure toutes les opérations necéssaires.

La dernière étape consiste à configurer l'authentification.

\-> FQDN du **JMS** utilisé dans la procédure: *jitsi.mondomaine.fr*.

* **Installer et configurer les vidéobridges (JVB).**

Le ports **udp/10000** doit donc être ouvert vers ces machines.

\-> FQDNs des **JVB**s utilisés dans la procédure: *jvb1.mondomaine.fr* et *jbv2.mondomaine.fr*.

### Installation du JMS:

---

* Ajouter le dépôt Jitsi

```
echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | apt-key add - apt update
```

* Installer Apache:

```
apt -y install apache2
```

* Installer Jitsi Meet:

```
apt -y install jitsi-meet
```

* Pendant l'installation, le FQDN du serveur sera demandé, il faut indiquer celui du **JMS** *(jitsi.mondomaine.fr)*
* Générer le certificat électronique:

```
/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh
```

* Tester la connexion au serveur Jitsi Meet.

Note: les conférences à 2 fonctionnent en P2P (donc sans passer par le vidéobridge). Il faut effectuer les tests avec au moins avec 3 clients pour vérifier que les flux audio et vidéo sont transmis correctement.

* Configuration du Load Balancing:

Ouvrir et éditer le fichier */etc/jitsi/videobridge/sip-communicator.properties*, il devrait ressembler à ceci:

```
org.ice4j.ice.harvest.DISABLE_AWS_HARVESTER=true org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=meet-jit-si-turnrelay.jitsi.net:443 org.jitsi.videobridge.ENABLE_STATISTICS=true org.jitsi.videobridge.STATISTICS_TRANSPORT=muc org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=localhost org.jitsi.videobridge.xmpp.user.shard.DOMAIN=auth.jtisi.mondomaine.fr org.jitsi.videobridge.xmpp.user.shard.USERNAME=jvb org.jitsi.videobridge.xmpp.user.shard.PASSWORD=7sM1g8yw org.jitsi.videobridge.xmpp.user.shard.MUC_JIDS=JvbBrewery@internal.auth.jtisi.mondomaine.fr org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=728f25ec-a170-40f5-a7f1-b4f7b9d8c98a
```

Ajouter ces lignes:

```
org.jitsi.videobridge.DISABLE_TCP_HARVESTER=true org.jitsi.videobridge.xmpp.user.shard.DISABLE_CERTIFICATE_VERIFICATION=true
```

* Rédémarrer *jicofo*:

```
service jicofo restart
```

* Arrêter et désactiver *jitsi-videobridge2*:

```
service jisti-videobridge2 stop
systemctl disable jitsi-videobridge2.service
```

### Installation du premier JVB

---

* Ajouter le dépôt Jitsi:

```
echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | apt-key add -
apt update
```

* Installer le videobridge Jitsi:

```
apt -y install jitsi-videobridge2
```

* Pendant l'installation, le FQDN du serveur sera demandé, il faut indiquer celui du **JMS** *jitsi.mondomaine.fr*, pas celui du **JVB** !
* Editer le fichier */etc/jitsi/videobridge/sip-communicator.properties*
* Ajouter ces lignes:

```
org.jitsi.videobridge.DISABLE_TCP_HARVESTER=true org.jitsi.videobridge.xmpp.user.shard.DISABLE_CERTIFICATE_VERIFICATION=true
```

* Modifier la ligne *org.jitsi.videobridge.xmpp.user.shard.HOSTNAME* (remplacer *localhost* par le FQDN ou l'adresse IP publique du **JMS)**:

```
#org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=localhost
org.jitsi.videobridge.xmpp.user.shard.HOSTNAME=jitsi.mondomaine.fr
```

* Pour faciliter l'identification du vidéobridge dans les logs du **JMS**, modifier la ligne *org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME* (indiquer le nom court du **JVB** à la place du hash généré pendant l'installation):

```
#org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=8d81e0ef-4370-4103-b1b4-e9ee295f972c
org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=jvb1
```

* Modification des credentials

Sur le **JMS**: ouvrir le fichier */etc/jitsi/videobridge/config* et récupérer le mot de passe indiqué sur la ligne *JVB_SECRET*.

```
# sets the shared secret used to authenticate to the XMPP server
JVB_SECRET=MotDePasseDuJMS
```

Sur le **JVB** : remplacer le mot de passe par celui du **JMS** dans les fichiers */etc/jitsi/videobridge/config* et */etc/jitsi/videobridge/sip-communicator.properties*.

Fichier */etc/jitsi/videobridge/config:*

```
# sets the shared secret used to authenticate to the XMPP server
#JVB_SECRET=MotDePasseDuJVB
JVB_SECRET=MotDePasseDuJMS
```

Fichier */etc/jitsi/videobridge/sip-communicator.properties:*

```
#org.jitsi.videobridge.xmpp.user.shard.PASSWORD=MotDePasseDuJVB
org.jitsi.videobridge.xmpp.user.shard.PASSWORD=MotDePasseDuJMS
```

* Redémarrer le *jitsi-videobridge2*:

```
service jitsi-videobridge2 restart
```

### Installation des autres JVBs

---

* Répétez les étapes du chapitre *Installation du premier JVB*.
* N'oubliez pas de changer le nom pour chaque **JVB** dans */etc/jitsi/videobridge/sip-communicator.properties* !
```
org.jitsi.videobridge.xmpp.user.shard.MUC_NICKNAME=jvbXX
```

### Tests

* "jouer" avec les videobriges: arrêter et redemarrer les démons *jitsi-videobridge2* des **JVBs**.
* Démarrer une conférence avec au moins 3 participants (avec Chrome/Chomium de préférence): la bascule entre les **JVBs** est transparente, les sessions se figent pendant quelques secondes mais ne DOIVENT PAS s'interrompre.
* Consulter les logs de Jicofo du **JMS** pour vérifier si les **JVB**s s'inscrivent et se désinscrivent correctement:

```
tail -f /var/log/jitsi/jicofo.log |grep '/jvb'

Jicofo 2020-05-09 12:06:16.114 INFOS: [22] org.jitsi.jicofo.xmpp.BaseBrewery.removeInstance().386 Removed brewery instance: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
Jicofo 2020-05-09 12:06:16.114 INFOS: [22] org.jitsi.jicofo.xmpp.BaseBrewery.notifyInstanceOffline().184 A bridge left the MUC: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
Jicofo 2020-05-09 12:06:16.114 INFOS: [22] org.jitsi.jicofo.bridge.BridgeSelector.log() Removing JVB: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
Jicofo 2020-05-09 12:06:16.115 INFOS: [69] org.jitsi.jicofo.bridge.JvbDoctor.log() Stopping health-check task for: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01

Jicofo 2020-05-09 12:06:31.275 INFOS: [22] org.jitsi.jicofo.xmpp.BaseBrewery.processInstanceStatusChanged().330 Added brewery instance: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
Jicofo 2020-05-09 12:06:31.275 AVERTISSEMENT: [22] org.jitsi.jicofo.bridge.BridgeSelector.log() No pub-sub node mapped for jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
Jicofo 2020-05-09 12:06:31.276 INFOS: [22] org.jitsi.jicofo.bridge.BridgeSelector.log() Added new videobridge: Bridge[jid=jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01, relayId=null, region=null, stress=0,00]
Jicofo 2020-05-09 12:06:31.277 INFOS: [69] org.jitsi.jicofo.bridge.JvbDoctor.log() Scheduled health-check task for: jvbbrewery@internal.auth.jitsi.mondomaine.fr/jvb01
```

## Références

* Ce tutoriel est inspiré de <https://samynitsche.de/articles/jitsi-meet-load-balancing/>
* Doc GitHub Jitsi Meet <https://github.com/jitsi/jitsi-meet/wiki/jitsi-meet-load-balancing-installation-Ubuntu-18.04-with-MUC-and-JID>
