{
  description = "Qotidien et Gaming";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11"; # ou nixos-unstable
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }@inputs: {
    nixosConfigurations.dell_5485 = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
      ./configuration.nix
      impermanence.nixosModules.impermanence
      ];
    };
  };
}
