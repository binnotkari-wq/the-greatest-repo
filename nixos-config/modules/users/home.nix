{ pkgs, ... }:

{
  # Information de base sur l'utilisateur
  home.username = "benoit";
  home.homeDirectory = "/home/benoit";

  home.stateVersion = "25.11"; # Garder la version d'installation initiale

  # Activation de Home Manager lui-même
  programs.home-manager.enable = true;

  # Les paquets que tu installais avant via nix profile
  home.packages = with pkgs; [
    # bat
    fzf
    # ripgrep
    duf
    mc
    lynx
    btop
    htop
    nvtopPackages.amd
    pkgs.radeontop
    fastfetch
    compsize
    # tes autres outils...
  ];

  # Configuration de Git
  programs.git = {
    enable = true;
    settings = {
      user.name  = "binnotkari-wq";
      user.email = "benoit.dorczynski@gmail.com";
      init.defaultBranch = "main";
      core.editor = "nano";
      # Stocke le token de manière persistante sur ton disque (dans ~/.git-credentials)
      credential.helper = "store";
    };
  };

  # Configuration de btop (plus sympa qu'une installation simple)
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "solarized_dark";
      vim_keys = true;
    };
  };

  # Tu peux gérer ton .bashrc ici
  programs.bash = {
    enable = true;

# Ton message de bienvenue
    initExtra = ''
      echo "=== Installer un logiciel ==="
      echo "- nix-shell -p nomdulogiciel # le logiciel est isolé, il ne fera partie d'aucune génération. Ne sera plus présent au prochain reboot"
      echo "- flatpak install --user flathub nomdulogiciel # le flatpak sera installé dans le repo flatpak userspace, depuis flathub"
      echo
      echo "=== Supprimer les vieilles générations et nettoyer ==="
      echo "- sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 15 16 17 18 # indiquer les numéros de génération à supprimer"
      echo "- sudo nix-collect-garbage # supprimer les fichiers correspondants du store"
      echo
      echo "=== Mettre à jour ==="
      echo "- cd ~/Mes-Donnees/Git/nixos-config && nix flake update # update système"
      echo "- flatpak update -y # mise à jour flatpaks"
      echo "- cd ~/Mes-Donnees/Git/ && git init && git add . && git commit -m "description du commit" && git pull origin main && git push origin main # synchroniser le depot git des .nix"
      echo
      echo "=== Rebuild (à executer dans ~/Mes-Donnees/Git/nixos-config)"
      echo "- sudo nixos-rebuild test --flake .#dell_5485 # rebuild simple d'une nouvelle génération"
      echo "- sudo nixos-rebuild boot --flake .#dell_5485 # générer une nouvelle entrée de boot, suite au rebuild test"
      echo "- sudo nixos-rebuild switch --flake .#dell_5485 # rebuild et bascule en live sur la nouvelle génération, et génère une nouvelle entrée de boot"
      echo
      echo "=== outils de monitoring ==="
      echo "- duf - fastfetch - radeontop - btop - nvtop - compsize"
      echo "- sudo compsize /nix # analyser la compression btrfs du sous-volume @nix"
    '';


    # des exmeples d'alias
    shellAliases = {
      # ll = "ls -l";
      # update = "sudo nixos-rebuild switch --flake .#dell_5485";
      # garbage = "nix-collect-garbage -d";
    };

    # Variables de session
    sessionVariables = {
      FLATPAK_DOWNLOAD_TMPDIR = "$HOME/.flatpak-tmp";
      HISTTIMEFORMAT = "%d/%m/%y %T ";
    };

    # Pour ton script de gestion d'historique
    bashrcExtra = ''
      if [[ $SHLVL -eq 1 ]]; then
        history -s "# SESSION $(date +%s) $$"
        history -a
      fi
    '';
  };

  # --- GESTION DES FICHIERS (Optionnel) ---
  # Home Manager peut aussi copier des fichiers directement dans ton Home.
  # home.file.".config/mon-logiciel/config.conf".text = ''
  #   parametre = valeur
  # '';
}
