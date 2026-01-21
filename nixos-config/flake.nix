{
  description = "Configuration NixOS multi-machines de Benoit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11"; # Utilise la branche matching nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, impermanence, home-manager, ... }@inputs: {
    nixosConfigurations = {


      # --- CONFIGURATION 1 : DELL 5485 ---
      "dell-5485" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Activation des modules externes
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager

          # 2. Le matériel
          ./hosts/dell-5485/hardware-configuration.nix # celui généré par bootstrap.sh
          ./hosts/dell-5485/tuning.nix

          # 3. Tes modules de configuration système
          ./OS/core.nix
          ./OS/desktop_environment.nix
          ./OS/special_apps.nix
          ./OS/SteamOS.nix

          # 4. Tes modules de configuration utilisateur + home manager
          ./users/benoit.nix

          # 5. Configuration directe (anciennement configuration.nix)
          {
            system.stateVersion = "25.11";
            networking.hostName = "dell-5485";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.benoit = import ./users/benoit_home.nix;
          }
        ];
      };


      # --- CONFIGURATION 2 : Ryzen 5 3600 ---
      "r5-3600" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Activation des modules externes
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager

          # 2. Le matériel
          ./hosts/r5-3600/hardware-configuration.nix # celui généré par bootstrap.sh
          ./hosts/r5-3600/tuning.nix

          # 3. Tes modules de configuration système
          ./OS/core.nix
          ./OS/desktop_environment.nix
          # ./OS/special_apps.nix
          ./OS/SteamOS.nix

          # 4. Tes modules de configuration utilisateur + home manager
          ./users/benoit.nix

          # 5. Configuration directe (anciennement configuration.nix)
          {
            system.stateVersion = "25.11";
            networking.hostName = "r5-3600";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.benoit = import ./users/benoit_home.nix;
          }
        ];
      };


      # --- CONFIGURATION 3 : machine virtuelle ---
      "vm" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Activation des modules externes
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager

          # 2. Le matériel
          ./hosts/vm/hardware-configuration.nix # celui généré par bootstrap.sh
          ./hosts/vm/tuning.nix

          # 3. Tes modules de configuration système
          ./OS/core.nix
          ./OS/desktop_environment.nix
          # ./OS/special_apps.nix
          # ./OS/SteamOS.nix

          # 4. Tes modules de configuration utilisateur + home manager
          ./users/benoit.nix

          # 5. Configuration directe (anciennement configuration.nix)
          {
            system.stateVersion = "25.11";
            networking.hostName = "vm";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.benoit = import ./users/benoit_home.nix;
          }
        ];
      };


      # --- CONFIGURATION 4 : ISO PERSONNALISÉE ---
      "iso-auto" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # Module de base pour l'ISO (choisis minimal ou graphical)
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma-6.nix"

          # Importation de tes briques logicielles
          ./OS/core.nix
          ./OS/desktop_environment.nix
          ./OS/special_apps.nix
          ./OS/SteamOS.nix
          ./hosts/dell-5485/tuning.nix
          ./hosts/vm/tuning.nix
          ./hosts/r5-3600/tuning.nix
          ./users/benoit.nix # Pour avoir ton utilisateur et ses groupes

          # Configuration spécifique à l'ISO
          ({ lib, pkgs, ... }: {
            # On force la désactivation des parties "disques physiques" qui feraient échouer l'ISO
            boot.initrd.luks.devices = lib.mkForce {};
            fileSystems = lib.mkForce {};


          # Auto-login pour ne pas avoir à taper de mot de passe sur le Live USB
          services.displayManager.autoLogin = {
            enable = true;
            user = "nixos"; # L'utilisateur par défaut de l'ISO
          };

          # Indispensable : inclure ton repo Git directement dans l'ISO
          # pour que bootstrap.sh soit utilisable sans internet
          system.activationScripts.copyMyConfig = ''
            mkdir -p /home/nixos/nixos-config
            cp -R ${self}/* /home/nixos/nixos-config/
            chown -R nixos /home/nixos/nixos-config
          '';

          # On s'assure que les paquets sont bien mis en cache
          isoImage.squashfsCompression = "zstd"; # Meilleur compromis taille/vitesse
          })
        ];
      };


    };
  };
}
