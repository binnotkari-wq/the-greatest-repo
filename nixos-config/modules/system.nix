{ config, pkgs, lib, ... }:

{
  # --- ACTIVATION ZRAM --- pour supporter le root en RAM
  zramSwap.enable = true;
  zramSwap.memoryPercent = 30; # Utilise jusqu'à 30% de tes 12Go si besoin

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
