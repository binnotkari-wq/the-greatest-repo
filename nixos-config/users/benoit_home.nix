{ pkgs, ... }:

{

  # List packages installed for user only
  home.packages = with pkgs; [
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

  # Configuration de btop
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "solarized_dark";
      vim_keys = true;
    };
  };

  # Configuration de bash
  programs.bash = {
    enable = true;

    initExtra = ''
      echo -e "\e[36m=== Raccourcis =====================================\e[0m"
      echo -e "- \e[33mapps : liste des logiciels CLI / TUI astucieux"
      echo -e "- \e[33msys : commandes système spécifique Nixos"
      echo -e "- \e[33mmaj : commande de mises à jour système et git"
      echo -e "\e[36m=== Installer un logiciel =====================================\e[0m"
      echo -e "- \e[33mnix shell nixpkgs#nomdulogiciel\e[0m # le logiciel est isolé, il ne fera partie d'aucune génération. Ne sera plus présent au prochain reboot"
      echo -e "- \e[33mflatpak install --user flathub nomdulogiciel\e[0m # le flatpak sera installé dans le repo flatpak userspace, depuis flathub"
      echo -e "\e[36m=== outils de monitoring harware ======================================\e[0m"
      echo -e "- \e[33mradeontop - nvtop - powertop\e[0m"

      # Tes instructions d'historique peuvent rester ici ou dans bashrcExtra
      if [[ $SHLVL -eq 1 ]]; then
        history -s "# SESSION $(date +%s) $$"
        history -a
      fi
    '';

    # Alias
    shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch --flake .#$(hostname)";
    garbage = "nix-collect-garbage -d";
    # Utilisation de '' (doubles apostrophes) pour autoriser les guillemets à l'intérieur
    apps = ''awk '/environment.systemPackages = with pkgs; \[/ {flag=1; next} /\];/ {flag=0} flag' ~/Mes-Donnees/Git/nixos-config/OS/core.nix'';
    sys = ''printf "\e[33msudo nixos-rebuild test --flake .#$(hostname)\e[0m : rebuild simple d'une nouvelle génération\n\e[33msudo nixos-rebuild boot --flake .#$(hostname)\e[0m : générer une nouvelle entrée de boot\n\e[33msudo nixos-rebuild switch --flake .#$(hostname)\e[0m : rebuild, bascule live et boot\n\e[33mnix build .#nixosConfigurations.$(hostname).config.home-manager.users.benoit.home.activationPackage\e[0m : mettre à jour les données utilisateur d'après benoit_home.nix\n\e[33msudo nix-env --list-generations --profile /nix/var/nix/profiles/system\e[0m : lister les générations\n\e[33msudo nix-env -p /nix/var/nix/profiles/system --delete-generations 15 16 17\e[0m : supprimer les générations\n\e[33msudo nix-collect-garbage\e[0m : supprimer les fichiers du store\n" '';
    upd = ''printf "\e[33mcd ~/Mes-Donnees/Git/nixos-config && nix flake update\e[0m : update système\n\e[33mflatpak update -y\e[0m : mise à jour flatpaks\n\e[33mcd ~/Mes-Donnees/Git/ && git add . && git commit -m \"description du commit\" && git pull origin main && git push origin main\e[0m : synchroniser le depot git des .nix\n" '';
    };

    # Variables de session
    sessionVariables = {
      FLATPAK_DOWNLOAD_TMPDIR = "$HOME/.flatpak-tmp";
      HISTTIMEFORMAT = "%d/%m/%y %T ";
    };
  };

}
