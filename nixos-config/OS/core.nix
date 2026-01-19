{ config, lib, pkgs, modulesPath, ... }:

{
  # --- BOOTLOADER & KERNEL ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "quiet" "splash" "loglevel=3" "rd.systemd.show_status=false" ];


  # --- BOOT GRAPHIQUE ---
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };


  # --- SYSTEMES DE FICHIERS ---
  fileSystems."/" =
    { device = "none";
      fsType = "tmpfs"; # / est un tmpfs : son contenu est donc effacé au redémarrage. Quelques fichiers doivent persister, il y a donc des bind mount créé à chaque démaraage depuis /nix (voir plus bas dans la partie PERSISTENCE)
      options = [ "defaults" "size=2G" "mode=755" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@home" "noatime" "compress=zstd" "ssd" "discard=async" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-label/NIXOS";
      fsType = "btrfs";
      options = [ "subvol=@nix" "noatime" "compress=zstd" "ssd" "discard=async" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [
    { device = "/dev/disk/by-label/SWAP"; }
  ];

  zramSwap.enable = true;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin


  # --- PERSISTENCE ---
  # On utilise le sous-volume /nix (déjà persistant) pour stocker les rares fichiers de /etc et /var à conserver entre chaque démarrage.
  # Si /home n'est pas sur une partion ou des sous-volume btrfs disincts, il faut le lister ici.
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
      # "/home"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
    ];
  };


  # --- RÉSEAU ---
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";


  # --- LOCALISATION (FR) ---
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };
  console.keyMap = "fr";


  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };


  # --- MATÉRIEL & SERVICES ---
  hardware.bluetooth.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;


  # --- ACCELERATION GRAPHIQUE (Vulkan) ---
  hardware.graphics = {
  enable = true;
  enable32Bit = true; # Souvent utile pour Steam aussi
  };


  # --- SON (Pipewire) ---
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


  # --- OPTIMISATION NIX ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
}
