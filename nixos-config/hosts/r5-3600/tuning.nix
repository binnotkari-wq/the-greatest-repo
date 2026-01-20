{ config, lib, pkgs, ... }:

{

  # UUID LUKS2 spécifique à la machine (injecté à l'installation de NixOS par mon script bootstrap)
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/REPLACE_ME_LUKS_UUID";

  # La nouvelle manière officielle de débloquer l'overclocking/undervolting
  hardware.amdgpu.overdrive.enable = true;

  # CoreCtrl pour la gestion CPU/GPU (Qt/KDE)
  programs.corectrl.enable = true;

}
