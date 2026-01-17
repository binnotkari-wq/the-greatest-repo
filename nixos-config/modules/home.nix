{ pkgs, ... }:

{
  # Information de base sur l'utilisateur
  home.username = "benoit";
  home.homeDirectory = "/home/benoit";
  home.stateVersion = "25.11"; # Garder la version d'installation initiale

  # Activation de Home Manager
  programs.home-manager.enable = true;

  # List packages installed for user only
  home.packages = with pkgs; [
    fzf
    duf
    mc
    lynx
    btop
    htop
    powertop
    nvtopPackages.amd
    radeontop
    fastfetch
    compsize
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
      echo -e "\e[36m=== Installer un logiciel =====================================\e[0m"
      echo -e "- \e[33mnix shell nixpkgs#nomdulogiciel\e[0m # le logiciel est isolé, il ne fera partie d'aucune génération. Ne sera plus présent au prochain reboot"
      echo -e "- \e[33mflatpak install --user flathub nomdulogiciel\e[0m # le flatpak sera installé dans le repo flatpak userspace, depuis flathub"
      echo
      echo -e "\e[36m=== Supprimer les vieilles générations et nettoyer ============\e[0m"
      echo -e "- \e[33msudo nix-env -p /nix/var/nix/profiles/system --delete-generations 15 16 17 18\e[0m # indiquer les numéros de génération à supprimer"
      echo -e "- \e[33msudo nix-collect-garbage\e[0m # supprimer les fichiers correspondants du store"
      echo
      echo -e "\e[36m=== Mettre à jour =============================================\e[0m"
      echo -e "- \e[33mcd ~/Mes-Donnees/Git/nixos-config && nix flake update\e[0m # update système"
      echo -e "- \e[33mflatpak update -y\e[0m # mise à jour flatpaks"
      echo -e '- \e[33mcd ~/Mes-Donnees/Git/ && git init && git add . && git commit -m "description du commit" && git pull origin main && git push origin main\e[0m # synchroniser le depot git des .nix'
      echo
      echo -e "\e[36m=== Rebuild (à executer dans ~/Mes-Donnees/Git/nixos-config)===\e[0m"
      echo -e "- \e[33msudo nixos-rebuild test --flake .#dell_5485\e[0m # rebuild simple d'une nouvelle génération"
      echo -e "- \e[33msudo nixos-rebuild boot --flake .#dell_5485\e[0m # générer une nouvelle entrée de boot, suite au rebuild test"
      echo -e "- \e[33msudo nixos-rebuild switch --flake .#dell_5485\e[0m # rebuild et bascule en live sur la nouvelle génération, et génère une nouvelle entrée de boot"
      echo
      echo -e "\e[36m=== outils de monitoring ======================================\e[0m"
      echo -e "- \e[33mduf - fastfetch - radeontop - btop - nvtop - powertp - compsize\e[0m"
      echo -e "- \e[33msudo compsize /nix\e[0m # analyser la compression btrfs du sous-volume @nix"
    '';

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
}
