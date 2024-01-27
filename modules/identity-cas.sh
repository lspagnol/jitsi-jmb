#!/bin/bash

########################################################################
# Récupération des infos utilisateur à partir des attributs CAS
########################################################################

# Prérequis pour la récupération d'attributs CAS:
# - le serveur CAS **DOIT** retourner les attributs nécessaires
# - le module d'authentification CAS / Apache **DOIT** être configuré
#   pour prendre en compte les attributs CAS
#   -> directive "CASAuthNHeader CAS_UID" dans la section protégée / CAS

auth_uid="${HTTP_CAS_UID,,}"
auth_name="${HTTP_CAS_GIVENNAME^^} ${HTTP_CAS_SN^^}"
auth_mail="${HTTP_CAS_MAIL,,}"
