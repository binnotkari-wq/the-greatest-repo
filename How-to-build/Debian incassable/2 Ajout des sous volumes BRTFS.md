2 Ajout des sous volumes BRTFS
========================

Installer Debian d’abord (LVM+LUKS >> Btrfs unique), puis créer les sous-volumes ensuite

➡️ C’est ce que tu as fait

➡️ C’est la méthode normale pour ce schéma

Dans ce cas, tu crées /@, /@home, /@log, etc. après l’installation, puis tu déplaces les données et modifies /etc/fstab.

Cette méthode est officielle et fonctionnelle.


## Création des sous-volumes BRTFS
```

sudo mount -o subvolid=5 /dev/mapper/vda1_crypt /mnt
sudo btrfs subvolume create /mnt/@  
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@overlay
sudo btrfs subvolume create /mnt/@snapshot
sudo mkdir -p /overlay /snapshot
```

## Ensuite modif du fstab
D'abord recupérer l'uuid du volume brtfs
```
sudo btrfs filesystem show
```

Ajouter dans fstab :
```
UUID=413eee0c-61ff-4cb7-a299-89d12b075093   /     btrfs  defaults,subvol=/@ 0 0
UUID=413eee0c-61ff-4cb7-a299-89d12b075093  /home  btrfs  defaults,subvol=/@home 0 0
pareil pour overlay et snapshot
```
Et commenter la ligne
```
/dev/mapper/vda1_crypt / btrfs defaults,subvol=rootfs 0 0
```

## Copie des données utilisateur
A ce moment il faut copier le contenu du dossier utilisateur dans le chemin du sous-volume (qui n'est pas encore monté). Ainsi au redémarrage quand le sous-volume @home sera monté dans /home, il contiendra toutes les données utilisateur (dans le cas contraire...plantage au moment du login!)
```
sudo cp -a /home/* /mnt/@home
```

## Redémarrage
Et tout de suite apres on reboot
Après redémarrage on peut vérifier que les sous-volumes osnt bien créés
```
sudo btrfs subvolume list
```


## Rien à voir
Astuce comme ça glanée sur internet, pour mettre à jours les montages quand on a modifié fstab :
```
systemctl daemon-reload  
mount -a  
```

