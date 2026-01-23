{ pkgs, lib, nixpkgs, self, ... }:

{
  imports = [
    # On utilise le module officiel de l'ISO
    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-combined.nix"
  ];

  # --- CONFIGURATION DE L'ENVIRONNEMENT LIVE ---
  nixpkgs.hostPlatform = "x86_64-linux";
  # networking.hostName = "iso-expert";
  # services.displayManager.autoLogin = { enable = true; user = "nixos"; };

  # --- LE CACHE OFFLINE ---
  # On demande à l'ISO d'embarquer les systèmes complets des machines
  isoImage.storeContents = [
    self.nixosConfigurations."dell-5485".config.system.build.toplevel
    self.nixosConfigurations."r5-3600".config.system.build.toplevel
    self.nixosConfigurations."vm".config.system.build.toplevel
  ];

  # Script pour copier ton code source sur le bureau de l'ISO
  # system.activationScripts.copyConfig = ''
    # mkdir -p /home/nixos/nixos-config
    # cp -R ${self}/* /home/nixos/nixos-config/
    # chown -R nixos /home/nixos/nixos-config
  # '';


  }



