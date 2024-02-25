#!/bin/bash

########################################################################
# Récupération des infos utilisateur à partir des attributs CAS
########################################################################

# Prérequis pour la récupération d'attributs CAS:
# - le serveur CAS **DOIT** retourner les attributs nécessaires
# - le module d'authentification CAS / Apache **DOIT** être configuré
#   pour prendre en compte les attributs CAS
#   -> directive "CASAuthNHeader CAS_UID" dans la section protégée / CAS

# ATTENTION: vérifier que le SSO ne retourne pas de valeurs encodées en
# base64 !

#auth_uid="${HTTP_CAS_UID,,}"
auth_uid="${REMOTE_USER,,}"
auth_mail="${HTTP_CAS_MAIL,,}"
auth_name="${HTTP_CAS_GIVENNAME^^} ${HTTP_CAS_SN^^}"

auth_givenname="{HTTP_CAS_GIVENNAME}"
auth_sn="${HTTP_CAS_SN}"
