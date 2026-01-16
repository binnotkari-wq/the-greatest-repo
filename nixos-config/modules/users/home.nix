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

  # Gestions détaillée des logiciels et de leurs préférences utilisateur
  programs.git = {
    enable = true;
    settings.user.name = "binnotkari-wq";
    settings.user.email = "benoit.dorczynski@gmail.com";
    settings = {
      init.defaultBranch = "main";
      core.editor = "nano";      # Ou ton éditeur préféré
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
    interactiveShellInit = ''
      echo "=========================================="
      echo "   Bienvenue sur NixOS (Dell 5485)        "
      echo "=========================================="
    '';


    # Tes alias (on garde ceux qu'on a vu avant)
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake .#dell_5485";
      garbage = "nix-collect-garbage -d";
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
