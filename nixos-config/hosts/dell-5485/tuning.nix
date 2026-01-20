{ config, lib, pkgs, ... }:

{

  # UUID LUKS2 spécifique à la machine (injecté à l'installation de NixOS par mon script bootstrap)
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/REPLACE_ME_LUKS_UUID";

  # La nouvelle manière officielle de débloquer l'overclocking/undervolting
  hardware.amdgpu.overdrive.enable = true;

  # CoreCtrl pour la gestion CPU/GPU (Qt/KDE)
  programs.corectrl.enable = true;

  # Gestion TDP APU (Ryzen 3500U)
  environment.systemPackages = with pkgs; [
    ryzenadj
  ];

  # Alias pour le confort
  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };
}
