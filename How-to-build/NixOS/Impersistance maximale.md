Impersistance maximale
======================

Objectif :

Mettre / en tmpfs.
Mettre en persistence uniquement ce qui est nécessaire dans /var et /etc.

Tout le reste est de toute facon virtuel ( /run, /dev, /proc, /sys) ou est impermanente car recrée à la volée à chaque démarrage par NIXOS sous forme de liens vers le store figé (/bin, /sbin, /usr, lib64, )

Les chemins et commande sont celles pour le rebuild d'un système existant

### Mesurer l'occupation de /

Pour voir la place qui va être occupée en ram par le tmpfs

Utiliser le script Monitor-Btrfs-Usage.sh fait par Gemini, qui annonce la taille du sousvolume  / chaque minute.


### Analyser l'utilisation de /var

On va voir la taille de tous les sous-dossiers : sudo du -sh /var/* | sort -h

```bash
 [benoit@dell5485:~]$ sudo du -sh /var/* | sort -h
0       /var/db
0       /var/empty
0       /var/spool
0       /var/tmp : Décision : Volatil.
4,0K    /var/lock
4,0K    /var/run
29M     /var/cache : Décision : Volatil. Le cache se reconstruira tout seul en RAM si besoin.
82M     /var/lib : Décision : Persistance sélective. Il faut fouiller un peu dedans pour ne garder que l'essentiel (Bluetooth, NetworkManager, etc.).
118M    /var/log : Décision : Volatil. Inutile de garder ça sur SSD. En cas de crash, les logs de la session actuelle seront en RAM, et au reboot, on repart à zéro.
```

Détail de /var/lib : sudo du -sh /var/lib/* | sort -h

```bash
[benoit@dell5485:~]$ sudo du -sh /var/lib/* | sort -h
0       /var/lib/AccountsService
0       /var/lib/machines
0       /var/lib/misc
0       /var/lib/portables
0       /var/lib/power-profiles-daemon
0       /var/lib/private
0       /var/lib/udisks2
4,0K    /var/lib/flatpak
4,0K    /var/lib/logrotate.status
4,0K    /var/lib/plymouth
16K     /var/lib/lastlog
20K     /var/lib/nixos : à persister car contient l'UID/GID de tes utilisateurs et d'autres états critiques du système
24K     /var/lib/bluetooth : à persister pour ne pas perdre tes appairages.
28K     /var/lib/cups : à persister si on souhaite avoir une imprimante et garder sa configuration
32K     /var/lib/NetworkManager : à persister pour garder tes connexions Wi-Fi et VPN
100K    /var/lib/upower : volatil, c'est un relevé de l'état du matériel comme les charges du clavier et souris (faulctatif)
1,8M    /var/lib/fwupd : à persister pour l'historique des mises à jour de tes firmwares (facultatif mais recommandé).
20M     /var/lib/sddm : volatil, ce sont souvent des avatars d'utilisateurs ou des caches d'écran de connexion.
60M     /var/lib/systemd : volatil, ne contient principalement que des logs de session, des timers et des coredumps. Pas besoin de garder ça.
```

### Déclaration des persistance  pour /etc et /var

```bash
{
  # On utilise le sous-volume /nix (déjà persistant) pour stocker 
  # les rares fichiers système rescapés de /etc.
  # si /home et /var ne sont pas sur des partions ou des sous-volumes btrfs disincts,
  # il faudra à la liste leur éléments à persister.
  environment.persistence."/nix/persist" = {
    # hideMounts = true; pour cacher les montages fictifs, mais utilise x-gvfs-hide, pas pertinent quand on a KDE
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
      # "/etc/adjtime"    # Heure BIOS/Système, pas vraiment besoin, se met à jour à chaque connection à internet
    ];
  };
}
```

Et on prépare les dossiers de ces éléments persistés, on va les mettre dans /nix/ (qui est un sous-volume btrfs persistant pour NIXOS) :

```bash
sudo mkdir -p /nix/persist/etc/NetworkManager/system-connections
sudo mkdir -p /nix/persist/var/lib/bluetooth
sudo mkdir -p /nix/persist/var/lib/NetworkManager
sudo mkdir -p /nix/persist/var/lib/nixos
sudo mkdir -p /nix/persist/var/lib/cups
sudo mkdir -p /nix/persist/var/lib/fwupd
sudo chmod -R 700 /nix/persist/etc/NetworkManager/system-connections
sudo chmod -R 700 /nix/persist/var/lib/bluetooth
sudo chmod -R 700 /nix/persist/var/lib/NetworkManager
sudo chmod -R 700 /nix/persist/var/lib/nixos
sudo chmod -R 700 /nix/persist/var/lib/cups
sudo chmod -R 700 /nix/persist/var/lib/fwupd
```

Et on copie les éléments à persister :

```bash
sudo cp -ra /etc/NetworkManager/system-connections/. /nix/persist/etc/NetworkManager/system-connections/
sudo cp -ra /var/lib/bluetooth /nix/persist/var/lib/
sudo cp -ra /var/lib/NetworkManager /nix/persist/var/lib/
sudo cp -ra /var/lib/nixos /nix/persist/var/lib/
sudo cp -ra /var/lib/cups /nix/persist/var/lib/
sudo cp -ra /var/lib/fwupd /nix/persist/var/lib/
sudo cp -a /etc/machine-id /nix/persist/etc/machine-id # pas d'option r car c'est un fichier, pas un répertoire
```

NB : On utilise l'option -a (archive) pour conserver les droits, les dates et les liens symboliques, ce qui est crucial pour le Bluetooth et NetworkManager.

### Mise en place du zram

Dans le fichier .nix dévoué aux propriété système

```bash
{
  # Activation du ZRAM pour supporter le root en RAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin
}
```


### / en tmpfs


Puisque ton monitoring confirme que ton root est léger, voici comment modifier ton hardware-configuration.nix.
1. Configuration du FileSystem

Remplace ton entrée pour / par celle-ci :

```bash
fileSystems."/" = {
  device = "none";
  fsType = "tmpfs";
  options = [ "defaults" "size=2G" "mode=755" ];
};
```

Note : Avec 2 Go, tu es large. Si tu constates que tu satures (rare), tu pourras monter à 3 ou 4 Go.
2. Nettoyage de l'ancien Btrfs

Puisque / est maintenant en RAM, tu n'as plus besoin de monter le sous-volume @ sur /.

Tu peux soit supprimer la ligne du sous-volume @ dans ton hardware-configuration.nix.
Soit, plus prudemment pour l'instant, le monter ailleurs (ex: /mnt/old_root) si tu veux récupérer des fichiers avant de le supprimer définitivement.


### Rebuild



sudo nixos-rebuild test --flake .#dell_5485
Ceci va générer le build en n'allant pas plus loin que la vérification et la génération des fichiers.
Le pc va probablement se bloquer, ou wayland / kde crashent, puisqu'on a entrainé la suppression en live de /.
Si on a acces à TTY2 ou TTY3 (ctrl+alt+F2 ou F3) on peut faire un reboot.
Ensuite, intégrer cette génération au bootloader : 
sudo nixos-rebuild boot --flake .#dell_5485
reboot
Une nouvelle entrée sera alors présente dans le bootloader, on peut booter dessus.

NB : si c'est fait au moment de l'installation de NIXOS depuis un live-cd, il n'y aura pas de crash lorsqon' fait la commande sudo nixos-install --flake .#dell_5485 puisque la cible n'est pas le système live-cd en cours d'exécution.




### Contrôle


Ensuite pour contrôler que les différents aménagements ont bien été appliqués :

```bash
zramctl # pour vérifier que le zram a bien été mis en place
mount | grep "on / type" # on doit voir "tmpfs" pour / dans le resultat"
df -h / # on verra que / est tout petit (même pas 100mo)
```

### Suppresion des sous-volumes BTRFS devenus inutiles

@ et @var ne sont à présent plus utilisés, puis / est en tmpfs et que /var en impermanence sauf quelques éléments persistés dans le volume @nix



1. Préparation : Accéder à la racine du disque

Pour supprimer des sous-volumes Btrfs, il faut d'abord monter la partition physique (sans spécifier de sous-volume) dans un dossier temporaire.

```bash
sudo mkdir -p /mnt/temp_btrfs_root
sudo mount /dev/nvme0n1p3 /mnt/temp_btrfs_root
```

2. Le grand ménage

Maintenant, on va lister ce qu'il y a là-dedans pour être sûr, puis on supprime.  Vérifie la liste (tu devrais voir @, @home, @nix, @var, etc.)
```bash
sudo btrfs subvolume list /mnt/temp_btrfs_root | grep -E "@|@var"
ID 256 gen 2910 top level 5 path @
ID 257 gen 2955 top level 5 path @home # on y touche pas !
ID 258 gen 2913 top level 5 path @nix # on y touche pas !
ID 259 gen 2910 top level 5 path @var # j'avais choisi de créer un sousvolume var lors de l'installation.
ID 260 gen 2804 top level 256 path @/srv # fait partie des souvolumes crées par NIXOS lors de l'install
ID 261 gen 2753 top level 259 path @var/lib/portables # fait partie des souvolumes crées par NIXOS lors de l'install
ID 262 gen 2753 top level 259 path @var/lib/machines # fait partie des souvolumes crées par NIXOS lors de l'install
ID 263 gen 2910 top level 256 path @/tmp # fait partie des souvolumes crées par NIXOS lors de l'install
ID 264 gen 2910 top level 259 path @var/tmp # fait partie des souvolumes crées par NIXOS lors de l'install
ID 265 gen 628 top level 5 path @blank # le snapshot vide btrfs qui me servait à faire la réinitialisation de / lorsque le tmpfs n'était pas encore en place
ID 266 gen 2758 top level 256 path @/@blank # le snapshot vide btrfs qui me servait à faire la réinitialisation de / lorsque le tmpfs n'était pas encore en place
```

Donc on va supprimer tout ça : 

```bash
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@/tmp
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@/srv
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@/@blank
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@var/tmp
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@var/lib/portables
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@var/lib/machines
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@var
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@blank

```

Note : Si tu avais créé un sous-volume @blank pour ton ancienne méthode de snapshot, tu peux aussi le supprimer

```bash
sudo btrfs subvolume delete /mnt/temp_btrfs_root/@blank
```

3. Nettoyage final

On démonte tout et on retire le dossier temporaire.

```bash
sudo umount /mnt/temp_btrfs_root
sudo rm -rf /mnt/temp_btrfs_root
```


C'est fini
