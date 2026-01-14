Fedora Kinoite 43 19/11/2025
========================

### Réglages

* Panneau de config, cavlier, activer verr num au démarrage. Ensuite aller dans la page de config de SDDM, et "appliquer la configuration de plasma"

* Pour lire les videos amazon prime : installer le flatpak de firefox source flathub et installer flatpak install org.freedesktop.Platform.ffmpeg-full -choisir derniere version)


### Rationnalisation infrastructure Flatpak

####  1. Remove the limited Fedora repo
```bash
flatpak remote-delete fedora
```

#### 2. Option 1: Full Repository:

Get access to everything Flathub (that include apps that are not officially maintained by their developers):

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

#### 3. Réinstaller tout ce qui a été enlevé suite au retrait du depot fedora (enfin on reinstalle que ce qui est utile et on en profite pour installer tout ce qu'on aime bien)
```bash
flatpak install flathub skanpage elisa okular kolourpaint gwenview kcalc librecad firefox gpt4all haruna heroic kate kdenlive kdiff3 keepassxc kiwix krita kstars ktorrent libreoffice marble openshot qemu org.virt_manager.virt-manager qownnotes steam net.wz2100.wz2100
```
Ne pas installer flatseal car il depend des runtimes GTK et Gnome. Tenacity egalement.

#### 4. pour voir les dépendences des flatpaks
```bash
flatpak list --app --columns=application,runtime
```

#### 5. pour supprimer les dépendences qui ne sont plus utilisées
```bash
flatpak remove --unused
```



### Environnement virtuel de bidouille
Ensuite mettre en place Toolbox
Permet de créer un nouvel environnement linux isolé mais sans aucune perte de performance, pour installer des rpm car pas de flatpak pour l'application, faire des tests, meme avec gui. Tout reste dans le repertoire utilisateur et n'est pas lié au système. La toolbox peut être supprimée à n'importe quel moment (et cela supprime tout ce qui a été fait ou installé dans la tooblox).

OSTREE ne sera jamais modifié.

```bash
toolbox create
toolbox enter fedora-toolbox-43
```
Une fois entré dans la toolbox, on peut ensuite installer des outils en CLI (liste à compléter)
```bash
sudo dnf install groff htop lynx pandoc mc
```


### Synchro et sauvegarde du téléphone
KDE n'utilise pas GVFS. 
Mais en mettant en place KDEconnect, le stockage du tel devient accessible par

Mémoire interne :
/run/user/1000/a28accf58fa24d9d8936d8d37f4153ce/storage/emulated

Carte SD actuelle :
/run/user/1000/a28accf58fa24d9d8936d8d37f4153ce/storage/60FA-E036




