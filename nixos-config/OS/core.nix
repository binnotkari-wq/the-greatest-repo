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


  # --- SYSTEMES DE FICHIERS : ADD-ON à hardware-configuration.nix ---
  # la génération automatique de harware-configuration ne detecte pas automatiquement les options de montage à l'installation (https://wiki.nixos.org/wiki/Btrfs)
  fileSystems = {
  "/".options = [ "defaults" "size=2G" "mode=755" ]; # / est un tmpfs : son contenu est donc effacé au redémarrage. Quelques fichiers doivent persister,voir plus bas dans la partie PERSISTENCE.
  "/home".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  "/nix".options = [ "noatime" "compress=zstd" "ssd" "discard=async" ];
  "/swap".options = [ "noatime" "ssd"];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Optimisations LUKS (appliquées uniquement si cryptroot est défini dans hardware-configuration.nix)
  # boot.initrd.luks.devices."cryptroot" = {
  #   allowDiscards = true;
  #   bypassWorkqueues = true;
  # };


  # --- ACTIVATION DU SWAP EN RAM COMPRESSEE (sera utilisé en priorité avant le swap sur disque) ---
  zramSwap.enable = true;
  zramSwap.priority = 100;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin


  # --- PERSISTENCE ---
  # On utilise le sous-volume /nix (déjà persistant) pour stocker les rares fichiers de /etc et /var à conserver entre chaque démarrage.
  # Les bind mount seront créés d'après cette liste.
  # Si /nix et /home ne sont pas sur une partion ou des sous-volume btrfs disincts, il faut les lister ici.
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
      # "/nix"
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
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };


  # --- MATÉRIEL & SERVICES ---
  hardware.bluetooth.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;
  hardware.enableAllFirmware = true;


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


  # --- TOOLBOX CLI ---
    environment.systemPackages = with pkgs; [
    # Logiciels CLI / TUI astucieux
    fzf         # recherche de fichiers
    mc          # gestionnaire de fichiers
    lynx        # navigateur web
    htop        # gestionnaire de processus
    btop        # gestionnaire de processus, plus graphique
    fastfetch   # affiche les caractéristiques du PC
    duf         # analyse  espace disque
    compsize    # analyse système de fichier btrfs : sudo compsize /nix
    git         # interface de versionning
    wget        # téléchargement de fichiers par http
    powertop    # gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
    vtm         # un desktop
    zellij      # un autre desktop
    musikcube   # lecteur de musique
    mpv         # lecteur vidéo
    pyradio     # webradio
    mdcat       # afficheur de fichiers Markdown
    slides      # lecteur de fichiers Markdown
    pciutils    # pour la commande lspci
    mprime      # Pour le stress test (Prime95)
    s-tui       # Interface graphique CLI pour monitorer fréquence/température
    clinfo      # Pour vérifier le support OpenCL
    amdgpu_top  # Un moniteur de ressources génial pour voir la charge du CPU/GPU AMD
    foot        # Un terminal qui ne dépend ni de KDE ni de Gnome, parfait dans une session Gamescope
    imagemagick # traitement et conversion d'images en batch
    groff       # manipulation de contenu texte et conversion de formats
    qpdf        # manipulation de fichiers pdf
  ];

}
