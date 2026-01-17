Fonction .nix pas pertinenete
=============================

### environnement.nix

Fichier completement inutilisé, ne servait pas vraiment à quelque chose

```bash
  # --- Autocompletion des commandes Bash ---
  # programs.bash.completion.enable = true;

  # --- Alias "upgrade" --- pour maintenance globale, écrire upgrade
  # dans le terminal executera ce qui suit :
  # environment.interactiveShellInit = ''
    # alias upgrade='
      # echo "🚀 Début de la mise à jour globale..."

      # 1. Mise à jour des dépôts (Flake)
      # cd ~/nixos-config && nix flake update

      # 2. Application de la configuration NixOS
      # sudo nixos-rebuild switch --flake ~/nixos-config#dell_5485

      # 3. Mise à jour des Flatpaks
      # if command -v flatpak > /dev/null; then
        # echo "📦 Mise à jour des Flatpaks..."
        # flatpak update -y
      # fi

      # 4. Nettoyage des vieux liens morts
      # echo "🧹 Nettoyage du store..."
      # nix-collect-garbage --delete-older-than 7d

      # echo "✅ Système à jour et nettoyé !"'
  # '';
```


### home.nix :

```bash

  # Logiciels finalement pas utilisés
    home.packages = with pkgs; [
    # bat
    # ripgrep
  ];



      # des exmeples d'alias
    shellAliases = {
      # ll = "ls -l";
      # update = "sudo nixos-rebuild switch --flake .#dell_5485";
      # garbage = "nix-collect-garbage -d";
    };

    # --- GESTION DES FICHIERS (Optionnel) ---
  # Home Manager peut aussi copier des fichiers directement dans ton Home.
  # home.file.".config/mon-logiciel/config.conf".text = ''
  #   parametre = valeur
  # '';
```

### boot.nix

```bash
  # boot.consoleLogLevel = 0;
  # boot.initrd.verbose = false;

  # --- INUTILE SI / EN TMPFS ---
  # --- VIDANGE / --- impermanence : à chaque démarrage, restauration d'un snaphot btrfs vide sur / , qui se retrouve donc vidangé à chaque démarrage, /home, nix, var étant des partions ou sous-volumes distinct ou gérés par le module de persistence (et donc relocalisés à l'abri dans /nix)
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
    # mkdir /mnt
    # mount -t btrfs /dev/nvme0n1p3 /mnt
    # btrfs subvolume delete /mnt/@
    # btrfs subvolume snapshot /mnt/@blank /mnt/@
    # umount /mnt
  # '';
```

### persistence.nix

```bash
    environment.persistence."/nix/persist" = {
    # hideMounts = true; pour cacher les montages fictifs, mais utilise x-gvfs-hide, pas pertinent quand on a KDE
      files = [
        "/etc/machine-id" # Identité unique du PC.
        # "/etc/adjtime"    # Heure BIOS/Système, pas vraiment besoin, se met à jour à chaque connection à internet
      ];
    }
```

### system.nix

```bash
      # --- ID MACHINE --- la déclaration de cette valeur permet d'avoir /etc/machine-id
  # qui se génère tout seul au démarrage (impermanence). Valeur à récupérer avant de
  # lancer l'installation de NIXOS avec la commande : dbus-uuidgen
  # environment.etc."machine-id".text = "9bdbb07d2b2d1f91b29afc3169657034";
  # NON vu avec Gemini, certains service peuvent en avoir besoin très tôt lors du démarrage.
  # Mieux vaut le persister.
```

### TDP.nix

```bash
    # hardware.cpu.amd.ryzen-smu.enable = true; # même chose que déclarer linuxKernel.packages.linux_zen.ryzen-smu dans le ssystempackages. ryzenadj n'en a en fait pas besoin. Et c'est un module à recompiler lorsqu'il y a mise à jour du noyau.
    # systemd.services.lactd.enable = true; # GTK, corectrl est plus adapté sur KDE
    # environment.systemPackages = with pkgs; [
    # linuxKernel.packages.linux_zen.ryzen-smu # ryzenadj n'en a en fait pas besoin. Et c'est un module à recompiler lorsqu'il y a mise à jour du noyau.
    # lact # GTK, corectrl est plus adapté sur KDE
    # ];


    # Si on veut systématiser une modif de TDP à chaque démarrage.
   # systemd.services.ryzenadj-limit = {
    # description = "Abaisse le TDP du Ryzen 3500U";
    # wantedBy = [ "multi-user.target" ];
    # serviceConfig = {
     # Type = "oneshot";
      # --stapm-limit, --fast-limit et --slow-limit en milliwatts (ex: 12000 = 12W)
      # ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=12000 --fast-limit=12000 --slow-limit=12000";
      # RemainAfterExit = true;
    # };
  # };
```