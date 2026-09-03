# Globinours pour YunoHost — paquet de test 1.0.0-rc.1

Ce paquet installe Globinours sur un domaine ou sous-domaine dédié. La version de test télécharge l’archive depuis un petit serveur HTTP local lancé sur la machine YunoHost ; aucun dépôt Git ni publication externe n’est nécessaire.

## Test local

Copier sur le serveur YunoHost le dossier du paquet sous `/root/globinours_ynh` et `globinours-1.0.0-rc.1.tar.gz` sous `/root/globinours-source/`.

Dans une première session SSH :

```bash
cd /root/globinours-source
python3 -m http.server 8123 --bind 127.0.0.1
```

Dans une seconde session SSH :

```bash
sudo yunohost app install /root/globinours_ynh --debug --force --no-remove-on-failure
```

Choisir un domaine ou sous-domaine libre. Après l’installation, ouvrir son URL et terminer la création du premier administrateur dans l’assistant Globinours.

Avant publication, remplacer l’URL locale par celle de l’archive officielle, recalculer son SHA-256 et remplacer `1.0.0~rc1~ynh1` par `1.0.0~ynh1`.
