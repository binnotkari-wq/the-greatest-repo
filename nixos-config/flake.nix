{
  description = "Configuration NixOS multi-machines de Benoit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, impermanence, home-manager, ... }@inputs:
  let
    # --- SOCLE TECHNIQUE ---
    base-modules = [
      # 1. Activation des modules externes communs
      impermanence.nixosModules.impermanence
      home-manager.nixosModules.home-manager
      # 2. Configuration commune à toutes les machines
      ./OS/core.nix
      ./users/benoit.nix
      # 3. Configuration commune à tous les profils Home Manager
      {
        system.stateVersion = "25.11";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.benoit = import ./users/benoit_home.nix;
        home-manager.sharedModules = [
          {
            home.username = "benoit";
            home.homeDirectory = "/home/benoit";
            home.stateVersion = "25.11";
            programs.home-manager.enable = true;
          }
        ];
      }
    ];

  in {
    nixosConfigurations = {

      # DELL 5485 (portable principal)
      "dell-5485" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/dell-5485/hardware-configuration.nix
          ./platform_specific/CPU_AMD.nix
          ./platform_specific/APU_AMD.nix
          ./OS/plasma_base.nix
          ./OS/plasma_extended.nix
          ./OS/SteamOS.nix
          { networking.hostName = "dell-5485"; }
        ];
      };

      # RYZEN 5 3600 (Fixe / Gaming)
      "r5-3600" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/r5-3600/hardware-configuration.nix
          ./platform_specific/CPU_AMD.nix
          ./platform_specific/GPU_AMD.nix
          ./OS/plasma_base.nix
          ./OS/SteamOS.nix
          { networking.hostName = "r5-3600"; }
        ];
      };

      # Lenovo Thinkpad x240 (mobile)
      "len-x240" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/len-x240/hardware-configuration.nix
          ./platform_specific/CPU_intel.nix
          ./platform_specific/GPU_intel.nix
          ./OS/plasma_base.nix
          { networking.hostName = "len-x240"; }
        ];
      };

      # VM (Plasma)
      "vm" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/vm/hardware-configuration.nix
          ./OS/plasma_base.nix
          ./OS/plasma_extended.nix
          ./OS/SteamOS.nix
          ./platform_specific/CPU_AMD.nix
          ./platform_specific/CPU_intel.nix
          ./platform_specific/GPU_AMD.nix
          ./platform_specific/GPU_intel.nix
          ./platform_specific/GPU_nivida.nix
          ./platform_specific/qemu.nix
          { networking.hostName = "vm"; }
        ];
      };

      # VM (Gnome)
      "vm-gnome" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/vm-gnome/hardware-configuration.nix
          ./OS/gnome_base.nix
          ./OS/gnome_extended.nix
          ./OS/SteamOS.nix
          ./platform_specific/CPU_AMD.nix
          ./platform_specific/CPU_intel.nix
          ./platform_specific/GPU_AMD.nix
          ./platform_specific/GPU_intel.nix
          ./platform_specific/GPU_nivida.nix
          ./platform_specific/qemu.nix
          { networking.hostName = "vm-gnome"; }
        ];
      };

      # Confi live cible pour générer un ISO d'installation avec l'ensemble des packages disponibles offline
      "iso-auto" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs self nixpkgs; };
        modules = [
          ./iso.nix
        ];
      };

    };
  };
}
