{ config, pkgs, lib, ... }:

{
  # --- BOOTLOADER & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

    # On garde le silence pour que Plymouth soit bien visible
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];
  # boot.consoleLogLevel = 0;
  # boot.initrd.verbose = false;

  # --- INUTILE SI / EN TMPFS ---
  # --- VIDANGE / --- impermanence : à chaque démarrage, restauration d'un snaphot btrfs vide sur / , qui se retrouve donc vidangé à chaque démarrage, /home, nix, var étant des partions ou sous-volumes distinct ou gérés par le module de persistence (et donc relocalisés à l'abri dans /nix)
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
    # mkdir /mnt
    # mount -t btrfs /dev/nvme0n1p3 /mnt
    # btrfs subvolume delete /mnt/@
    # btrfs subvolume snapshot /mnt/@blank /mnt/@
    # umount /mnt
  # '';

  # --- BOOT GRAPHIQUE ---
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
    # themePackages = [
    # pkgs.kdePackages.plymouth-kcm
    # pkgs.kdePackages.plasma-workspace
    # ];
  };
}
