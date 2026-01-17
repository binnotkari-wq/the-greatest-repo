{
  description = "Configuration NixOS multi-machines de Benoit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Ajoute ici tes autres inputs si nécessaire (home-manager, etc.)
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # C'est ici que tu définis le nom utilisé dans ton script (FLAKE_NAME)
      dell_5485 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # 1. Le matériel (écrasé par le script bootstrap)
          ./hosts/dell_5485/hardware-configuration.nix

          # 2. Tes modules de configuration (déportés)
          ./modules/file_systems.nix
          ./modules/system.nix
          ./modules/boot.nix
          ./modules/persistence.nix
          ./modules/users.nix
          ./modules/apps.nix
          ./modules/TDP.nix
          ./modules/gaming.nix

          # 3. Paramètres qui étaient dans configuration.nix
          {
            system.stateVersion = "25.11";

            # Optionnel : forcer le hostname pour qu'il corresponde au nom de la config
            networking.hostName = "dell_5485";
          }
        ];
      };

      # Si tu installes une AUTRE machine, tu pourras copier-coller
      # ce bloc ici avec un autre nom (ex: "nouveau_pc")
    };
  };
}
