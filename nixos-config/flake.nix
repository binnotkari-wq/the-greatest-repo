{
  description = "Quotidien et Gaming";

  inputs = {
    # Note : En janvier 2026, nixos-25.11 est la version stable actuelle.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11"; # Utilise la branche matching nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Ajout de la virgule avant les points de suspension
  outputs = { self, nixpkgs, impermanence, home-manager, ... }@inputs: {
    # Attention au nom de l'hôte : dell_5485 (doit correspondre à ton hostname)
    nixosConfigurations.dell_5485 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix # Ce fichier doit importer ./users.nix

        impermanence.nixosModules.impermanence

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # On passe les inputs à home.nix au cas où tu en aies besoin plus tard
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.benoit = import ./users/home.nix;
        }
      ];
    };
  };
}
