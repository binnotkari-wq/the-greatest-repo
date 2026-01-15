Impersistance
========================

https://github.com/nix-community/impermanence 

on vide / a chaque demarrage. Tout est régénéré d'apres les fichiers .nix. Mais de base, quelques éléments ne sont pas généré automatiquement, au bout, il faut ajouter les déclaration necessaires dans les fichiers .nix :


## Adapter les .nix

### charger le module impersistance dans flake.nix

A indiquer dans les inputs, les outputs et dans les modules.



### le mot de passe utilisateur
mot de passe user hashé dans users.nix (plus besoin de /etc/shadow)

OK.

### Le machine-id

Le /etc/machine-id est utilisé par systemd pour identifier ta machine (pour les logs, les baux DHCP, etc.). Il faut le persister en le déclarant, sinon il sera régénéré à chaque boot, ce qui peut poser des problèmes (ton routeur croira que c'est un nouveau PC à chaque fois).

Il faut récupérer le machine-id au moment de l'install
```bash
dbus-uuidgen dans ton terminal.
```

environment.etc."machine-id".text = "b736...ton_id_unique_ici";



Non : périmé, voir commentaire dans la fiche Impersistance maximale

### L'heure système (adjtime)

Celui-ci est un peu particulier. Il sert à compenser la dérive de l'horloge matérielle (BIOS). Si tu utilises la synchronisation réseau (NTP), ce qui est le cas par défaut sur KDE :
Nix

networking.timeServers = [ "0.fr.pool.ntp.org" "1.fr.pool.ntp.org" ];

NixOS remettra l'heure à jour dès qu'il aura internet. La persistance de adjtime est donc facultative si tu as une connexion stable.



### Le cas de /etc/NetworkManager/system-connections

Il doit être accessible dans /etc/NetworkManager/ mais on ne peut pas le déclarer : sans quoi, on perdrait les mots de passe des réseaux wifi
Pourquoi on ne peut pas simplement le mettre dans le /home ?

- NetworkManager est un service système qui tourne avec les privilèges root. Il s'attend à lire ses configurations dans /etc/NetworkManager/system-connections. S'il essayait de lire un fichier dans ton /home, il y aurait un risque de sécurité (un utilisateur pourrait modifier une connexion système pour rediriger le trafic).

- L'Œuf ou la Poule : NetworkManager démarre souvent avant que ton utilisateur ne soit connecté et que ses fichiers ne soient totalement disponibles (surtout si ton /home est chiffré).

- Les Droits d'Accès : Les fichiers de connexion Wi-Fi contiennent des mots de passe en clair. Ils doivent être en chmod 600 appartenant à root. Si tu les mets dans ton /home, tu mélanges des secrets système avec tes photos et documents, ce qui casse l'isolation.


Il existe une option dans KDE pour dire "Enregistrer ce mot de passe uniquement pour cet utilisateur". Dans ce cas, le mot de passe est stocké dans ton KWallet (dans ton /home).

    Pro : C'est dans ton /home (déjà persistant chez toi).

    Con : Le Wi-Fi ne se connectera jamais avant que tu n'aies tapé ton mot de passe de session. C'est pénible pour les mises à jour en ligne de commande ou le SSH.



La solution : Le "Bind Mount" (La magie de l'Impermanence)

C'est là que le module Impermanence est génial. Au lieu de déplacer le dossier dans ton /home, il va faire croire à NetworkManager que le dossier est dans /etc, alors qu'il est physiquement stocké sur ton disque persistant (là où se trouve ton /nix).
Ce que je te suggère pour ton Dell 5485 :

Puisque tu as déjà un sous-volume @nix (qui est persistant), nous allons créer un dossier dédié à la persistance système à l'intérieur de /nix.
1. Prépare le terrain (en ligne de commande) :
Bash

sudo mkdir -p /nix/persist/etc/NetworkManager/system-connections
sudo chmod -R 700 /nix/persist/etc/NetworkManager/system-connections

Et ajouter /etc/NetworkManager/system-connections dans le .nix de config de la persistance.



5) le "true impersistance" : le vidange de / à chaque reboot (du moins tout ce qui n'a pas été inclus dans persistence : tout ceci n'existe plus vraiment dans / car ces éléments existentent desormais dans /nix , et dans / ce ne seront plus que des liens générés à chaque démarrage).


## Vidange de / systematisée

### La préparation manuelle (Le snapshot vide)

Avant d'automatiser l'effacement, nous devons créer un "état zéro" (un sous-volume vide) que le système utilisera pour écraser la racine à chaque démarrage.

Lance ces commandes :
Bash

1. On monte la racine de ton disque Btrfs dans /mnt
sudo mount /dev/nvme0n1p3 /mnt

2. On crée un snapshot de ta racine actuelle qu'on appelle @blank
sudo btrfs subvolume snapshot /mnt/@ /mnt/@blank

3. On vide ce snapshot pour qu'il soit vraiment "propre"
sudo rm -rf /mnt/@blank/*

4. On démonte
sudo umount /mnt

### Le script de purge automatique

Maintenant, on va dire à NixOS : "Au démarrage, juste avant de monter les disques, supprime le sous-volume @ et recrée-le à partir de @blank".

Ouvre ton fichier modules/system/default.nix (ou ton configuration.nix) et ajoute ceci :
Nix

{ lib, ... }: # Assure-toi que 'lib' est présent dans les arguments en haut du fichier

{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /mnt
    mount -t btrfs /dev/nvme0n1p3 /mnt
    btrfs subvolume delete /mnt/@
    btrfs subvolume snapshot /mnt/@blank /mnt/@
    umount /mnt
  '';
}

### Pourquoi c'est sans danger pour toi ?

Grâce à ta structure lsblk, voici ce qui va se passer au reboot :

    / (racine) : Sera totalement effacé et reviendra à l'état neuf (grâce au script).

    /nix : Est sur un sous-volume à part. Il ne bouge pas. Tes logiciels et ta persistance restent là.

    /home : Est sur un sous-volume à part. Tes documents, ton bureau et ton nixos-config sont sauvés.

    /var : Est sur un sous-volume à part. Tes logs et bases de données restent là.

🚀 Le test final

    Fais un dernier sudo nixos-rebuild switch --flake .#dell_5485.

    Crée un fichier bidon à la racine pour tester : sudo touch /test_impermanence.

    Redémarre.

Si tout fonctionne :

    Le fichier /test_impermanence aura disparu.

    Ton Wi-Fi se connectera tout seul (car il est persisté dans /nix/persist).

    Ton mot de passe fonctionnera (car il est déclaré dans ton users.nix).



    Puisque ta racine / s'efface à chaque boot, n'oublie pas : si tu installes un nouveau service (comme un serveur d'impression, un VPN spécifique ou une base de données) et que tu vois qu'il perd sa configuration après un reboot, c'est simplement qu'il faut ajouter son dossier dans ton fichier persistence.nix.



     (j'ai juste du renseigner mon mot de passe : dans les persistence, j'avais indiqué le dossier system-connections, mais pas son contenu. Mais après le redémarrage suivant, j'ai bien eu ma connection automatique au wifi puisque lorsque j'avais renseigné le mot de passe, les fichiers de conf réseaux sont bien apparu dans le system-connections localisé dans /nix)

C'est exactement ça ! Tu viens de vivre le cycle complet de l'Impermanence :

    Au premier boot : Le dossier /etc/NetworkManager/system-connections était vide (car la racine était neuve).

    Pendant la session : Tu as tapé ton mot de passe. NetworkManager a créé un fichier. Grâce au module impermanence, ce fichier a été écrit "à travers" le lien directement dans /nix/persist.

    Au second boot : La racine a été effacée, mais le lien vers /nix/persist a été recréé. NetworkManager a "vu" le fichier comme s'il avait toujours été là.

C'est la preuve que ton "pont" de persistance est parfaitement opérationnel.