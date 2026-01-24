Commandes usuelles
==================

=== Installer un logiciel ===
- nix shell nixpkgs#nomdulogiciel # le logiciel est isolé, il ne fera partie d'aucune génération. Ne sera plus présent au prochain reboot
- flatpak install --user flathub nomdulogiciel # le flatpak sera installé dans le repo flatpak userspace, depuis flathub

=== Supprimer les vieilles générations et nettoyer ===
- sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 15 16 17 18 # indiquer les numéros de génération à supprimer
- sudo nix-collect-garbage # supprimer les fichiers correspondants du store

=== Mettre à jour ===
- cd ~/Mes-Donnees/the-greatest-repo/nixos-dotfiles && nix flake update # update système
- flatpak update -y # mise à jour flatpaks
- cd ~/Mes-Donnees/Git/ && git init && git add . && git commit -m "description du commit" && git pull origin main && git push origin main # synchroniser le depot git des .nix

=== Rebuild (à executer dans ~/Mes-Donnees/the-greatest-repo/nixos-dotfiles)
- sudo nixos-rebuild test --flake .#dell_5485 # rebuild simple d'une nouvelle génération
- sudo nixos-rebuild boot --flake .#dell_5485 # générer une nouvelle entrée de boot, suite au rebuild test
- sudo nixos-rebuild switch --flake .#dell_5485 # rebuild et bascule en live sur la nouvelle génération, et génère une nouvelle entrée de boot

=== outils de monitoring ===
- duf - fastfetch - radeontop - btop - nvtop - powertop - compsize
- sudo compsize /nix # analyser la compression btrfs du sous-volume @nix



sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000 # TDP : 15W
sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000 # TDP par défaut du 3500U : 25W
