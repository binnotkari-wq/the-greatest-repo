Post install
========================


### Datation de l'historique bash

```bash
export HISTTIMEFORMAT='%s '
export PROMPT_COMMAND='history -a'
echo "# SESSION $(date +%s) $$" >> ~/.bash_history

Mettre dans .bashrc
if [[ $SHLVL -eq 1 ]]; then
  history -s "# SESSION $(date +%s) $$"
  history -a
fi




Celle là marche bien
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile

```

Permet d'utiliser le script bash-history-export-md avec les infos datées et par session de chaque commandes qui ont été entrées dans le terminal.


### Installer le repo flathub en mode user

Par défaut aucun repo n'est enregistré dans Nixos : c'est parfait, pas besoin de supprimer les éventuels repo existants.

On créé donc tout de suite le repo user :

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

Après un reboot, installation des flapaks :
```bash
flatpak install --user flathub
```




### Git

Crée ton dossier :
mkdir ~/nixos-config.

Déplace les fichiers :
sudo mv /etc/nixos/* ~/nixos-config/.

Change les droits :
sudo chown -R $USER:users ~/nixos-config.

cd ~/nixos-config

git config --global user.email "benoit.dorczynski@gmail.com"
git config --global user.name "binnotkari-wq"


Ajoute l'adresse de ton dépôt GitHub
git remote add origin https://github.com/binnotkari-wq/nixos-config.git

Renomme la branche principale en 'main' (standard moderne)
git branch -M main

git add .
git commit -m "Installation initiale NixOS"

git push -u origin main
    - Username : binnotkari-wq
    - Password : Colle ici le Token que tu viens de copier. (Note : Rien ne s'affichera quand tu colles, c'est normal pour la sécurité. Colle et appuie sur Entrée).


Token de github :
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


Et si on reinstalle un nouveau PC, ou sur le meme pc :
sudo nixos-rebuild switch --flake github:TonPseudo/nixos-config#nom_du_pc




