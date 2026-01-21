{ config, pkgs, ... }:

{

  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;


  # --- LOGICIELS A SUPPRIMER ---
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.discover
  ];


  # --- LOGICIELS A INSTALLER ---
  environment.systemPackages = with pkgs; [
    kdePackages.filelight
    kdePackages.kate
    kdePackages.markdownpart
    kdePackages.kdialog
    kdePackages.kde-cli-tools
    kdePackages.kdeconnect-kde
    kdePackages.partitionmanager
    kdePackages.skanpage
    kdePackages.kolourpaint
    kdePackages.kompare
    kdePackages.kcalc
    kdePackages.ktorrent
    kdePackages.marble
    firefox # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    qownnotes
    haruna
    keepassxc
    kstars
    pandoc
  ];

}
