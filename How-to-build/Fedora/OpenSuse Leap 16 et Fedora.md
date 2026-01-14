# OpenSuse Leap 16 et Fedora

Pour l'instant, faire overlay sur partition physique. Si on se rend compte que ca ne fait pas trop de données, on fera un tmpfs.
Si on ne veut pas overlay, on peut choisir BTRFS sur / cela va installer un système qui fera des snapshot BTRFS qui seront accessibles directement dans GRUB, et donc le disque sera totalement crypté.

Sans overlay, on peut aussi avoir SELinux. Mais à noter que SELinux n'est pas très pas utile dans un environnement 100% userspace que j'aurais avec les flatpaks, et un /sysroot en ro + overlay



# Installation

## Ecran de démarrage avec Splash=silent

Spécifique OpenSuse Leap 16.
On a freshly installed Leap 16.0 systems, the plymouth bootsplash doesn't appear.
Judging from the plymouth debug log, **splash=silent** boot option is missing.
Once after adding this manually, the boot splash seems working.
And, one more interesting thing: once **when you have splash=silent in the installer boot, the option is carried to the installed system**, too :)


## Partitions

- /boot/EFI (512mo)
- /  (15Go, et en ext4 pour éviter sous-volumes et snapper qui gênent overlayfs)
- /home (ext4 taille extensible au maximum, chiffré)
- /sans point de montage (3Go ext4 à mettre à la suite de /home) MAIS NE PAS MONTER CETTE PARTITION pour éviter qu'elle ne soit dans fstab
- /swap (4go chiffré)


#### OpenSuse
Pour l'instant, ne pas choisi chiffrement de disque total (FDE). Pour les premiers tests overlay, chiffrer uniquement home et swap. 
Pour ce faire :
- lancer l'installateur une première fois
- partionner comme prévu, et appliquer un chiffrement total
- lancer l'installateur, puis l'interrompre.
- redémarrer
- relancer l'installateur, et supprimer / et /run/overlay et les recréer sans chiffrement : les partitions home et swap seront conservées chiffrées. Il sera demandé de les déverouiller avec le mot de passe choici précédemment.


#### Fedora
RAS, l'installateur permet de chiffrer les partition aux choix.

## Logiciels

#### OpenSuse
- Ne pas installer SELinux
- Installer uniquement utilitaires de base et KDE


#### Fedora
Envrionnement de base : KDE Plasma Workspace
Cocher:
- KDE spin initial setup
- KDE
C'est tout ! pour plus de détail sur le contenu des groupes de logiciels, voir https://pagure.io/fedora-comps/blob/main/f/comps-f43.xml.in

Même principe si installation avec Gnome.


# Mise en place Overlay

Procédure à refaire après une mise à jour de noyau. Peut-être que l'entrée grub personnalisée "mode mainteance" existera encore, mais ne pas s'y fier : elle sera périmée car il fautdra y changer le numero de version du noyau.

## Conditions

### Opensuse

Fonctione si :
- SELinux=0 en paramètre de kernel dans grub, ou si SELinux déselectionné dans les packages à installer.
- pas de BTRFS avec sousvolumes, et pas de Snapper
- pas d'encryption de / et de la partition overlay

### Fedora

Fonctionne si :
- SELinux=0 en paramètre de kernel dans grub
- pas de BTRFS avec sousvolumes, et pas de Snapper
- pas d'encryption de / et de la partition overlay


## Sauvegarde

### Opensuse 
```bash
sudo cp /boot/initrd-$(uname -r) /boot/initrd-$(uname -r).bak
sudo cp /etc/default/grub /etc/default/grub.bak
```

### Fedora
```bash
sudo cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bak
sudo cp /etc/default/grub /etc/default/grub.bak
sudo su
mkdir -p /boot/loader/entries/backup/
cp /boot/loader/entries/*.conf /boot/loader/entries/backup/
exit
```

## Préparation de grub pour le mode "disable-overlay"

### Opensuse
#### Edition du fichier de config
```bash
sudo nano /etc/grub.d/41_custom
```

#### Ajout du code
IL FAUT COPIER TOUT CECI JUSTE AU DESSUS DE "EOF" - en adaptant l'UUID de / bien sur, qu'on peut trouver en faisant lsblk -f, sans toucher au contenu existant

```bash
menuentry 'openSUSE Leap 16.0 (MAINTENANCE - RW)' --class opensuse --class gnu-linux --class gnu --class os {
    load_video
    set gfxpayload=keep
    insmod gzio
    insmod part_gpt
    insmod ext2
    search --no-floppy --fs-uuid --set=root a47cb538-3915-43e1-97f4-e2833ddc4005
    echo 'Chargement du noyau (Mode Maintenance)...'
    linux /boot/vmlinuz-6.12.0-160000.7-default root=UUID=a47cb538-3915-43e1-97f4-e2833ddc4005 splash=silent mitigations=auto quiet security= disable-overlay
    echo 'Chargement du ramdisk initial...'
    initrd /boot/initrd-6.12.0-160000.7-default
}
```

#### Régénérer le menu de grub :

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
#### Redémarrage
```bash
sudo reboot
```

### Fedora

Pour Fedora : selinux=0 passé en parmètre du kernel pour que l'overlay soit possible
En mode disable overlay, on peut enlever selinux=0 (selinux sera donc activé)


#### Récupération des chemins

```bash
KERNEL_PATH=$(sudo grubby --info=DEFAULT | grep '^kernel=' | cut -d= -f2 | tr -d '"')
INITRD_PATH=$(sudo grubby --info=DEFAULT | grep '^initrd=' | cut -d= -f2 | tr -d '"')
```

#### Création de l'entrée de MAINTENANCE (disable-overlay, SELinux activé)

On la crée en premier à partir du noyau vierge

```bash
sudo grubby --add-kernel="$KERNEL_PATH" \
--initrd="$INITRD_PATH" \
--title="Fedora - Maintenance (Disable Overlay)" \
--copy-default \
--args="disable-overlay"
```

#### Création de l'entrée de remise à zéro de l'overlay (reset-overlay, SELinux activé)

On la crée en premier à partir du noyau vierge

```bash
sudo grubby --add-kernel="$KERNEL_PATH" \
--initrd="$INITRD_PATH" \
--title="Fedora - Purge (Reset Overlay)" \
--copy-default \
--args="reset-overlay"
```

#### Appliquer selinux=0 uniquement au noyau par défaut et changer le titre :

```bash
sudo grubby --update-kernel=DEFAULT --args="selinux=0"
```

On créé une variable qui est le chemin complet du fichier de l'entrée par défaut, puis on y remplace le contenu de "title" par un nom plus en cohérence :
```bash
CONF_FILE="/boot/loader/entries/$(sudo grubby --info=DEFAULT | grep '^id=' | cut -d= -f2 | tr -d '"').conf"
sudo sed -i 's/^title .*/title Fedora - Overlay Mode/' "$CONF_FILE"
```

#### Vérification

Pour être certain que tout est en ordre, listez vos entrées de démarrage :

```bash
sudo grubby --info=ALL | grep -E "title=|args="
```

#### Redémarrage
```bash
sudo reboot
```

Quelques précisions utiles :

> Persistance : Ces modifications survivront aux mises à jour du système, car Fedora utilise le mécanisme BLS.

> Ordre de démarrage : Si vous souhaitez que l'entrée avec disable-overlay devienne celle par défaut à l'avenir, vous pourrez utiliser sudo grubby --set-default-index=X.

> Note sur SELinux : En plus de selinux=0, il est parfois recommandé d'ajouter enforcing=0 pour une désactivation totale, mais selinux=0 suffit généralement pour empêcher le chargement du sous-système au boot.

> Ajouter une option partout	sudo grubby --update-kernel=ALL --args="opt"

> Supprimer une option	sudo grubby --update-kernel=ALL --remove-args="opt"

> Voir les détails d'un index	sudo grubby --info=0



## Scripts initrd

### création du répertoire du module overlay
```bash
sudo mkdir /usr/lib/dracut/modules.d/99overlay/
```

### module-setup.sh

Editer / créer le fichier :
```bash
sudo nano /usr/lib/dracut/modules.d/99overlay/module-setup.sh
```

Y copier le contenu :
```bash
#!/bin/sh

check() {
    return 0
}

depends() {
    echo "base"
}

install() {
    # on peut essayer avec inst_hook pre-pivot 10 si jamais 99 est trop tardi
    inst_hook pre-pivot 99 "$moddir/overlay.sh"
    
    # modules noyau necessaires (une partie est sans doute déjà appelée dans la config par défaut. mais on rappelle ici quand même par sécurité)
    instmods overlay ext4 btrfs

    # Inclusion explicite des binaires utilisés dans overlay.sh
    # inst_multiple s'assure que ces commandes et leurs bibliothèques (.so) 
    # sont copiées dans l'initramfs.
    # (une partie est sans doute déjà appelée dans la config par défaut
    # mais on rappelle ici quand même par sécurité)
    inst_multiple \
        mount \
        umount \
        mkdir \
        rm \
        modprobe \
        sed \
        grep \
        lsblk \
        blkid \
        cut
}
```

Rendre exécutable :
```bash
sudo chmod +x /usr/lib/dracut/modules.d/99overlay/module-setup.sh
```
### overlay.sh

Editer / créer le fichier :
```bash
sudo nano /usr/lib/dracut/modules.d/99overlay/overlay.sh
```
Y copier le contenu :
```bash
#!/bin/sh

##### PARTIE PARAMETRAGE

# Adapter selon le choix de la partition qui recevra l'overlay, il faut indiquer son UUID (utiliser lsblk -f)
STORAGE_UUID="50b5e785-4e58-4ca0-90f9-d75956cd36ce"

# Point de montage souhaité pour cette partition ( condition : il doit déjà exister dans l'initrd ou l'initramfs : sudo lsinitrd /boot/initrd-$(uname -r) | grep "^drw")
OVERLAY_MNT="/run/overlay"

# Laisser par défaut
UPPERDIR="${OVERLAY_MNT}/upper"
WORKDIR="${OVERLAY_MNT}/work"


##### PARTIE MODES DE MAINTENANCE

# Pas besoin de créer une entrée permanente tout de suite :
# Au menu GRUB, appuie sur e sur l'entrée habituelle.
# A la fin de la ligne qui commence par "linux" : ajouter simplement un espace puis disable-overlay ou reset-overlay
# Appuyer sur Ctrl+X pour démarrer.
# Pour rendre cela permanent, créer une nouvelle entrée dans /etc/grub.d/40_custom qui copie ton entrée normale mais ajoute ce flag à la fin.

if grep -q "reset-overlay" /proc/cmdline; then
    echo "***************************************************"
    echo "ATTENTION : Demande de RESET de l'overlay détectée."
    echo "Toutes les modifications de l'OS seront effacées."
    echo "***************************************************"
    mkdir -p "$OVERLAY_MNT"
    mount -t ext4 -U "$STORAGE_UUID" "$OVERLAY_MNT" -o rw,relatime
    rm -rf "$UPPERDIR" "$WORKDIR"
    umount "$OVERLAY_MNT"
    echo "Reset terminé ! Le système va démarrer sur une base propre."
    reboot -f
fi

# Lire la ligne de commande du noyau de désactivation de l'overlay
if grep -q "disable-overlay" /proc/cmdline; then
    echo "MODE MAINTENANCE : Désactivation de l'overlay."
    # On quitte le script ici pour ne pas activer l'overlay
    return 0 2>/dev/null || exit 0
fi


##### PARTIE MODE OVERLAY

# 1. Charger le module
modprobe overlay

# 2. Verrouiller la racine (Anti-Drift)
mount -o remount,ro /sysroot

# 3. Monter la partition de stockage. (option à tester : en tmpfs)
mkdir -p "$OVERLAY_MNT"
mount -t ext4 -U "$STORAGE_UUID" "$OVERLAY_MNT" -o rw,relatime
# mount -t tmpfs -o size=4G,mode=755 tmpfs "$OVERLAY_MNT"

# 4. Suppression de l'éventuel contenu existant de l'overlay (purge pour garantir la non-persistance) --> inutile si $OVERLAY_MNT est monté en tempfs
# rm -rf "$UPPERDIR" "$WORKDIR"

# 5. Créer les répertoires
mkdir -p "$UPPERDIR" "$WORKDIR"

# 6. MONTAGE DE L'OVERLAY SUR LA RACINE (/sysroot)
# Note : on n'utilise plus 'seclabel' ni 'defcontext' car SELinux est désactivé.
# On active metacopy et redirect_dir pour les performances et la cohérence Btrfs ou Ext4.
mount -t overlay overlay -o lowerdir=/sysroot,upperdir="$UPPERDIR",workdir="$WORKDIR",redirect_dir=on,metacopy=on /sysroot

# 7. AJUSTEMENT DU FSTAB DANS L'OVERLAY
# Pour éviter que le système ne tente de remonter la racine en RW - à activer en cas d'erreur sinon laisser commenté
# sed -i 's|/dev/.* / ext4 |overlay / overlay |' /sysroot/etc/fstab    
```


Rendre exécutable :
```bash
sudo chmod +x /usr/lib/dracut/modules.d/99overlay/overlay.sh
```

### Généreration de l'initrd

#### OpenSuse
```bash
sudo dracut --force --add overlay --add-drivers "overlay ext4 btrfs"
```

#### Fedora
```bash
sudo dracut --force --add overlay --add-drivers "overlay ext4 btrfs"
```


On peut vérifier si dracut a bien généré un initrd contenant les scripts overlay :
```bash
sudo lsinitrd /boot/initrd-$(uname -r) | grep overlay
```
On doit voir les scripts dans les chemins de l'initrd qui vient d'être généré. On peut vérifier la présence des autres modules et binaires

### Redémarrage
```bash
sudo reboot
```


# Opérations post-install (RW mode)

## KDE connection

Il faut autoriser KDE Connect à communiquer :
```bash
sudo firewall-cmd --permanent --zone=public --add-service=kdeconnect
sudo firewall-cmd --reload
```

## Arrêt des taches de fond

### Pour toute distrib RPM

Empêcher tout appel d'un logiciel tiers à faire une mise à jour de package rpm.
N'a aucune conséquence sur zypper ou dnf. Ce service permet au autres logiciels de communiquer de se servir zypper ou dnf pour provoquer des mises à jour.

```bash
sudo systemctl mask packagekit
```

Et au cas où, pour le réactiver :
```bash
sudo systemctl unmask packagekit
sudo systemctl enable --now packagekit
```

### Opensuse
```bash
sudo systemctl disable --now snapper-timeline.timer snapper-cleanup.timer \
backup-rpmdb.timer backup-sysconfig.timer logrotate.timer man-db.timer \
wtmpdb-rotate.timer systemd-tmpfiles-clean.timer btrfs-balance.timer \
btrfs-defrag.timer btrfs-scrub.timer btrfs-trim.timer zypper-refresh.timer
```

Explication :
- btrfs et snapper : c'est explicite
- systemd-tmpfiles-clean.timer : Il parcourt /tmp et /var/tmp pour supprimer les vieux fichiers. Comme le upper de l'overlay est soit déjà en RAM ou soit purgé au reboot, ce service est redondant.
- logrotate.timer : Il déplace, compresse et supprime des fichiers dans /var/log. Sur un système en RAM, cela ne sert à rien et consomme du CPU/RAM.
- man-db.timer : Met à jour l'index des pages de manuel. C'est totalement inutile pendant une session utilisateur.
- wtmpdb-rotate.timer : Gère la rotation de la base de données des connexions utilisateurs (/var/lib/wtmpdb).
- backup-rpmdb.timer : Sauvegarde la base de données des paquets installés (plusieurs Mo à chaque fois).
- backup-sysconfig.timer : Sauvegarde les fichiers de configuration de /etc/sysconfig.
- zypper-refresh.timer :  rafraîchit les dépôts en arrière-plan (ce qui remplit /var/cache/zypp)

### Fedora
La commande systemctl list-timers ne renvoi que très peu de résultats : il n'y a que logrotate.timer

```bash
sudo systemctl disable --now logrotate.timer
```

## Personnalisation logiciels système

### Opensuse


#### Installation
```bash
sudo zypper install nano partitionmanager lynx filelight flatpak kdeconnect-kde
```


#### Suppression

```bash
sudo zypper remove akregator-lang kaddressbook-lang kleopatra-lang kmail-lang kontact-lang korganizer-lang pim-data-exporter-lang pim-sieve-editor-lang akregator kaddressbook kleopatra korganizer pim-data-exporter pim-sieve-editor patterns-kde-kde_pim kontact kmail MozillaFirefox-translations-common kmahjongg-lang kmines-lang kpat-lang kreversi-lang ksudoku-lang libreoffice-base libreoffice-filters-optional libreoffice-l10n-fr libreoffice-mailmerge libreoffice-qt5 libreoffice-qt6 phonon-vlc-lang vlc-vdpau MozillaFirefox kmahjongg kmines kpat kreversi ksudoku libreoffice-writer libreoffice-math libreoffice-draw libreoffice-calc libreoffice-pyuno phonon-vlc-qt6 phonon-vlc-qt5 patterns-games-games patterns-kde-kde_games patterns-kde-kde_office patterns-office-office libreoffice-impress vlc libreoffice libreoffice-l10n-en libreoffice-icon-themes opensuse-welcome-launcher akonadi-calendar-tools-lang akonadi-contacts-lang akonadi-import-wizard-lang akonadi-lang akonadi-search-lang kalendarac kdepim-addons-lang kdepim-runtime-lang kmail-account-wizard-lang konversation-lang ktnef libKPim6AkonadiCalendar6-lang libKPim6AkonadiMime6-lang libKPim6CalendarSupport6-lang libKPim6EventViews6-lang libKPim6IncidenceEditor6-lang libKPim6Tnef6-lang mbox-importer-lang messagelib-lang opensuse-welcome akonadi-calendar-tools akonadi-import-wizard akonadi-search kdepim-addons kmail-account-wizard konversation kdepim-runtime mbox-importer libKPim6Tnef6 libKPim6IncidenceEditor6 libKPim6ImportWizard6 libKPim6AddressbookImportExport6 akonadi-plugin-mime akonadi-plugin-contacts akonadi-plugin-calendar akonadi libKPim6MailImporterAkonadi6 ktnef-debug-categories libKPim6EventViews6 libKPim6MailCommon6 libKPim6AkonadiXml6 libKPim6AkonadiAgentBase6 libKPim6CalendarSupport6 libKPim6AkonadiCalendar6 messagelib akonadi-calendar libKPim6PimCommonAkonadi6 libKPim6AkonadiMime6 libKPim6AkonadiSearch6 libKPim6AkonadiContactWidgets6 akonadi-mime libKPim6AkonadiWidgets6 libKPim6AkonadiContactCore6 libKPim6AkonadiCore6 akonadi-contacts libKPim6AkonadiPrivate6 discover xterm kate gwenview okular skanlite wacomtablet-kcm6 wacomtablet-kcm6-lang drkonqi6 drkonqi6-lang kuiviewer kuiviewer-lang
```

#### Redémarrage

```bash
sudo reboot
```

#### Nettoyage

```bash
sudo zypper clean
sudo zypper clean -a
sudo zypper verify
sudo rm -rf /var/cache/PackageKit/*
sudo rm -rf /var/lib/PackageKit/*
```

#### Redémarrage
```bash
sudo reboot
```

Opensuse utilise 6,5 Go de disque après cette desinstallation. Utilisation mémoire en machine virtuelle : 1,3 Go


### Fedora

#### Installation

Déjà tout ce qu'il faut. Et si on veut rajouter des logiciels en CLI : utiliser toolbox (voir à la fin du tuto), ca créera un environnement d'execution dans l'espace utilisateur.
On peut enlever ce qu'on ne veut pas :

#### Suppression

```bash
sudo dnf remove krfb* plasma-discover* *gnome*
```

Astuce : On peut chercher l'existence de paquets installés en cherchant dans leur nom :
```bash
dnf list --installed | grep "nom-du-paquet"
```

#### Redémarrage
```bash
sudo reboot
```

#### Nettoyage
```bash
sudo dnf autoremove
sudo dnf clean all
sudo dnf check
sudo rm -rf /var/cache/PackageKit/*
sudo rm -rf /var/lib/PackageKit/*
```

#### Redémarrage
```bash
sudo reboot
```
Fedora utilise 6,6 Go de disque après cette desinstallation. Utilisation mémoire en machine virtuelle : 1,3 Go

## Mise en place flatpak

*Process valable pour toute distrib. Une fois en place, les installation de flatpaks devront se faire avec la commande flatpak install --user flathub nom_du_logiciel*

### Lister les éventuels repos existants
```bash
sudo flatpak remotes
```

### Supprimer les éventuels repos existants qu'on vient d'identifier :
```bash
sudo flatpak remote-delete
```
 
### Installer le repo flathub en mode user
```bash
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Reconfiguration du dossier temporaire de flatpack dans le dossier utilisateur

Par défaut, Flatpak peut utiliser /var/tmp pour extraire les fichiers. Pour éviter cela, forcez-le à utiliser un dossier dans votre /home (qui est sur votre disque persistant). On specifie donc dans .bashrc un nouveau dossier dans la variable dont se sert flatpack pour le chemin des fichiers tléchargés :

```bash
echo 'export FLATPAK_DOWNLOAD_TMPDIR="$HOME/.flatpak-tmp"' >> ~/.bashrc
```

Et créer le dossier en question : 
```bash
mkdir -p ~/.flatpak-tmp
```
### Redémarrage
```bash
sudo reboot
```

# Opérations post-install  (RO mode)

## Installation Flatpaks


### Environnement KDE

```bash
flatpak install --user flathub skanpage elisa okular kolourpaint kate kompare gwenview kcalc librecad firefox gpt4all haruna heroic kate kdenlive keepassxc kiwix krita kstars ktorrent libreoffice marble openshot org.virt_manager.virt_manager.Extension.Qemu org.virt_manager.virt-manager qownnotes steam net.wz2100.wz2100
```

Parfois flatpak n'arrive pas a savoir si on est en branche stable ou master sur virt-manager (et cela provoque l'erreur "libvirt.libvirtError: binary '/app/bin/virtqemud' does not exist in $PATH: No such file or directory" lorsqu'on veut créer la connection utilisateur). Alors il faut faire :
```bash
flatpak run org.virt_manager.virt-manager//stable
```


### Environnement Gnome

```bash
flatpak install --user flathub skanpage elisa okular kolourpaint kate kompare gwenview kcalc librecad firefox gpt4all haruna heroic kate kdenlive keepassxc kiwix krita kstars ktorrent libreoffice marble openshot org.virt_manager.virt_manager.Extension.Qemu org.virt_manager.virt-manager qownnotes steam net.wz2100.wz2100
```



## Toolbox

Créer un environnement d'execution dans le repertoire utilisateur.

```bash
toolbox create
toolbox enter
sudo dnf install groff htop lynx mc pandoc
```

## Datation de l'historique bash

```bash
export HISTTIMEFORMAT='%s '
export PROMPT_COMMAND='history -a'
echo "# SESSION $(date +%s) $$" >> ~/.bash_history
```

Permet d'utiliser le script bash-history-export-md avec les infos datées et par session de chaque commandes qui ont été entrées dans le terminal.
