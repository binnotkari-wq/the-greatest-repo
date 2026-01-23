{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kodi-wayland
    pandoc                       # infrasctructure d'interprétation de fichiers textes et conversions
    kiwix                        # Interpréteur de fichiers wikimedia offline
    llama-cpp-vulkan             # moteur LLM pour IA local, avec interface web type Gemini / Chat GPT
    libreoffice-qt-fresh         # attention, beaucoup de dépendances
    hunspell                     # pour libreoffice
    hunspellDicts.fr-classique   # pour libreoffice
    hunspellDicts.fr-reforme1990 # pour libreoffice
    hunspellDicts.fr-moderne     # pour libreoffice
    hunspellDicts.fr-any         # pour libreoffice
    warzone2100                  # :)
    # heroic                     # C'est l'un des rares cas où le Flatpak est souvent recommandé par la communauté NixOS. Comme Heroic gère des jeux provenant de magasins qui ne supportent pas Linux nativement (Epic/GOG), l'isolation Flatpak fournit un environnement plus "standard" que les jeux Windows apprécient.:
    gimp                         # montage photo, retouche avancé
    pdfarranger                  # manipulateur de fichiers pdf
    handbrake                    # conversion de flux audio et vidéo
    gnome-boxes                  # gestionnaire de machines virtuelles
  ];
}
