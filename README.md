# Globinours pour YunoHost — 1.0.0-rc.3

Ce paquet installe Globinours sur un domaine ou sous-domaine dédié. Il télécharge une archive immuable de l’application depuis le dépôt Forgejo officiel, puis vérifie son empreinte SHA-256 avant installation.

## Installation de test

Depuis un clone du paquet présent sur le serveur YunoHost :

```bash
sudo yunohost app install /root/globinours_ynh --debug --force --no-remove-on-failure
```

Choisir un domaine ou sous-domaine libre. Après l’installation, ouvrir son URL et terminer la création du premier administrateur dans l’assistant Globinours.

Pour tester une mise à niveau du paquet :

```bash
sudo yunohost app upgrade globinours -u /root/globinours_ynh --debug
```

Globinours utilise ses propres comptes applicatifs : l’intégration LDAP et l’authentification SSO YunoHost ne sont donc pas utilisées.
