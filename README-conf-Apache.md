# Accès aux CGIs de "Jitsi Meet Booking" (JMB)

Vous devez modifier la configuration du virtualhost de Jitsi Meet pour que le GCI de l'interface de gestion soit accessible. L'ajout sera fait juste après le
bloc *Shibboleth*.

* Editez le fichier */etc/apache2/sites-available/##FQDN##.conf*, le bloc *Shibboleth* doit ressembler à ceci:
```
  <Location /login>
    AuthType shibboleth
    ShibRequestSetting requireSession true
    ShibRequestSetting redirectToSSL 443
    ShibUseHeaders On
    Sethandler shib
    ProxyPass http://localhost:8888/login
    ProxyPassReverse http://localhost:8888/login
    Require valid-user
  </Location>
```

* Ajoutez ceci juste après:
```
  # Afficher le lien "Planifiez vos réunions" en haut de la page
  # d'accueil de Jitsi Meet
  Alias /body.html /opt/jitsi-jmb/inc/body.html
  <Location /body.html>
    Require all granted
  </Location>

  # Logo (si disponible)
  #Alias /logo.png /opt/jitsi-jmb/etc/logo.png
  #<Location /logo.png>
  #  Require all granted
  #</Location>

  # Accès au CGI de l'interface de gestion
  <Location /booking.cgi>
    AuthType shibboleth
    ShibRequestSetting requireSession true
    ShibRequestSetting redirectToSSL 443
    ShibUseHeaders On
    Sethandler shib
    Require valid-user
    ProxyPass           http://localhost:80/booking.cgi
    ProxyPassReverse    http://localhost:80/booking.cgi
  </Location>
```

* Redémarrez *Apache*:
```
service apache2 restart
```

* Connectez-vous au CGI avec un navigateur Web pour vérifier qu'il fonctionne: *https://##FQDN##/booking.cgi*

* Redémarrez *Jicofo*
```
service jicofo restart
```
