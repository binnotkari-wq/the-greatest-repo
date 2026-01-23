{ config, pkgs, ... }:

{
  # --- ENVIRONNEMENT DE BUREAU ---
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # --- LOGICIELS A SUPPRIMER ---
  environment.gnome.excludePackages = with pkgs; [
  ];

  # --- LOGICIELS A INSTALLER ---
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-extension-manager      # Très pratique pour gérer les extensions sans passer par le navigateur
    firefox                      # natif car pour une meilleure intégration système (KDE Connect, gestion des mots de passe, accélération matérielle). Le Flatpak peut parfois briser le sandboxing interne de Firefox.
    fragments                    # Équivalent de KTorrent (Client BitTorrent GTK)
    pika-backup                  # Pour les sauvegardes, s'intègre parfaitement
    loupe                        # Visionneuse d'images moderne
    gnome-secrets                # gestionnaire de mots de passe compatible keepass
    meld                         # comparateurs de fichiers et dossiers
    zim                          # prise de notes et bobliothèque Markdown
    apostrophe                   # editeur / visualiseur avancé de Markdown
    foliate                      # lecteur ebook
    drawing                      # petit programme de dessin, identique à Paint
    lollypop                     # lecteur de musique
    celluloid                    # lecteur de vidéos
  ];
}
