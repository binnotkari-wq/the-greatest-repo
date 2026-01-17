{ config, pkgs, lib, ... }:

{
  # --- ID MACHINE --- la déclaration de cette valeur permet d'avoir /etc/machine-id
  # qui se génère tout seul au démarrage (impermanence). Valeur à récupérer avant de
  # lancer l'installation de NIXOS avec la commande : dbus-uuidgen
  # environment.etc."machine-id".text = "9bdbb07d2b2d1f91b29afc3169657034";
  # NON vu avec Gemini, certains service peuvent en avoir besoin très tôt lors du démarrage.
  # Mieux vaut le persister.

  # --- ACTIVATION ZRAM --- pour supporter le root en RAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin

  # --- RÉSEAU ---
  networking.hostName = "dell_5485";
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

  # --- INTERFACE GRAPHIQUE (KDE Plasma) ---
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
