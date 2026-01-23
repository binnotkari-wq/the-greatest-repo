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
    kdePackages.filelight        # analyseur d'espace disque
    kdePackages.kate             # éditeur de texte avancé
    kdePackages.markdownpart     # module Markdownp pour Kate
    kdePackages.kdialog          # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kde-cli-tools    # bibliothèque tout simple pour afficher des fenètres grâce à un script
    kdePackages.kdeconnect-kde   # connection avec smartphone
    kdePackages.partitionmanager # gestionnaire de partitions disque
    kdePackages.skanpage         # interface scanners
    kdePackages.kolourpaint      # petit programme de dessin, identique à Paint
    kdePackages.kompare          # comparaison de fichiers et répertoires
    kdePackages.kcalc            # calculatrice
    kdePackages.ktorrent         # gestionnaire de téléchargement torrents
    firefox                      # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    qownnotes                    # prise de notes et bobliothèque Markdown
    haruna                       # lecteur vidéo
    keepassxc                    # portefeuille de mots de passe
  ];
}
