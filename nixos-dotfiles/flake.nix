{
  description = "Configuration NixOS multi-machines de Benoit";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, home-manager, ... }@inputs:
  let
    user_name = "benoit";
    current_stable_version = "25.11";

    # --- SOCLE TECHNIQUE ---
    base-modules = [
      impermanence.nixosModules.impermanence
      home-manager.nixosModules.home-manager
      # 2. Configuration commune à toutes les machines
      ./OS/core.nix
      ./users/${user_name}.nix
      {
        system.stateVersion = current_stable_version;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users."${user_name}" = import ./users/${user_name}_home.nix;
        home-manager.sharedModules = [
          {
            home.username = user_name;
            home.homeDirectory = "/home/${user_name}";
            home.stateVersion = current_stable_version;
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
          ./OS/plasma_apps.nix
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

      # VM
      "vm" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = base-modules ++ [
          ./hosts/vm/hardware-configuration.nix
          ./OS/plasma_base.nix
          # ./OS/CLI_tools.nix
          ./platform_specific/qemu.nix
          { networking.hostName = "vm"; }
        ];
      };

    };
  };
}
