# Ce contenu doit être adapté pour réfléter les spécificité de la plateforme et du cpu, des modules kernel. On peut vérifier ces infos en faisant sudo nixos-generate-config --root /mnt . Après vérification, il faudra supprimer les fichiers .nix qui ont été générés dans /mnt/etc/nixos/
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
