Commandes usuelles
==================

=== Installer provisoirement un logiciel ===
nix-shell -p nomdulogiciel # le logiciel est isolé, il ne fera partie d'aucune génération. Ne sera plus présent au prochain reboot
flatpak install --user flathub nomdulogiciel # le flatpak sera installé dans le repo flatpak userspace, depuis flathub

=== Supprimer les vieilles générations et nettoyer ===
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 15 16 17 18 # indiquer les numéros de génération à supprimer
sudo nix-collect-garbage # supprimer les fichiers correspondants du store

=== Mettre à jour ===
cd ~/Mes-Donnees/Git/nixos-config && nix flake update # update système
flatpak update -y # mise à jour flatpaks

=== Rebuild (à executer dans ~/Mes-Donnees/Git/nixos-config)
cd ~/Mes-Donnees/Git/nixos-config && sudo nixos-rebuild test --flake .#dell_5485 # rebuild simple
cd ~/Mes-Donnees/Git/nixos-config && sudo nixos-rebuild boot --flake .#dell_5485 # générer une nouvelle entrée de boot, suite au rebuild test
cd ~/Mes-Donnees/Git/nixos-config && sudo nixos-rebuild switch --flake .#dell_5485 # rebuild et bascule en live sur la nouvelle génération
git init && git add . && git commit -m "description du commit" && git pull origin main && git push origin main # synchroniser le depot git des .nix

=== outils de monitoring ===
duf - fastfetch - radeontop - btop - nvtop - compsize
sudo compsize /nix # analyser la compression btrfs du sous-volume @nix
