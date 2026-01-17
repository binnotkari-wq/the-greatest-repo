{ config, lib, pkgs, ... }:

{
  # Débloque l'accès aux tensions pour CoreCtrl et le noyau
  boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];

  # Configuration optimisée CoreCtrl (Qt)
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;
  };

  # On garde ryzenadj pour le laptop (APU)
  environment.systemPackages = with pkgs; [
    ryzenadj
  ];

  # Alias pour le confort
  environment.shellAliases = {
    ryzen-low = "sudo ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"; # TDP : 15W
    ryzen-default = "sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"; # TDP par défaut du 3500U : 25W
  };
}

    # hardware.cpu.amd.ryzen-smu.enable = true; # même chose que déclarer linuxKernel.packages.linux_zen.ryzen-smu dans le ssystempackages. ryzenadj n'en a en fait pas besoin. Et c'est un module à recompiler lorsqu'il y a mise à jour du noyau.
    # systemd.services.lactd.enable = true; # GTK, corectrl est plus adapté sur KDE
    # environment.systemPackages = with pkgs; [
    # linuxKernel.packages.linux_zen.ryzen-smu # ryzenadj n'en a en fait pas besoin. Et c'est un module à recompiler lorsqu'il y a mise à jour du noyau.
    # lact # GTK, corectrl est plus adapté sur KDE
    # ];


    # Si on veut systématiser une modif de TDP à chaque démarrage.
   # systemd.services.ryzenadj-limit = {
    # description = "Abaisse le TDP du Ryzen 3500U";
    # wantedBy = [ "multi-user.target" ];
    # serviceConfig = {
     # Type = "oneshot";
      # --stapm-limit, --fast-limit et --slow-limit en milliwatts (ex: 12000 = 12W)
      # ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=12000 --fast-limit=12000 --slow-limit=12000";
      # RemainAfterExit = true;
    # };
  # };
