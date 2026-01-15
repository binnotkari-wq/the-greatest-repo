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
    bat
    fzf
    ripgrep
    duf
    mc
    lynx
    btop
    htop
    nvtopPackages.amd
    pkgs.radeontop
    fastfetch
    # tes autres outils...
  ];

  # Gestions détaillée des logiciels et de leurs préférences utilisateur
  programs.git = {
    enable = true;
    userName = "binnotkari-wq";
    userEmail = "benoit.dorczynski@gmail.com";
    extraConfig = {
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


  # Si tu utilises Bash (par défaut sur NixOS), tu peux gérer ton .bashrc ici
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake .#dell5485";
      garbage = "nix-collect-garbage -d";
    };
  };

  # --- GESTION DES FICHIERS (Optionnel) ---
  # Home Manager peut aussi copier des fichiers directement dans ton Home.
  # home.file.".config/mon-logiciel/config.conf".text = ''
  #   parametre = valeur
  # '';
}
