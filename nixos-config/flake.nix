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
      # C'est ici que tu définis le nom utilisé dans ton script (FLAKE_NAME)
      dell_5485 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Activation des modules externes
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager

          # 2. Le matériel (généré par bootstrap.sh))
          ./hosts/dell_5485/hardware-configuration.nix

          # 3. Tes modules de configuration (déportés)
          ./modules/file_systems.nix
          ./modules/system.nix
          ./modules/boot.nix
          ./modules/persistence.nix
          ./modules/users.nix
          ./modules/apps.nix
          ./modules/TDP.nix
          ./modules/gaming.nix

          # 4. Configuration directe (anciennement configuration.nix)
          {
            system.stateVersion = "25.11";
            networking.hostName = "dell_5485";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.benoit = import ./modules/home.nix;
          }
        ];
      };

      # Si tu installes une AUTRE machine, tu pourras copier-coller
      # ce bloc ici avec un autre nom (ex: "nouveau_pc")
    };
  };
}
