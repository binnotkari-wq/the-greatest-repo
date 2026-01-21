{ config, pkgs, ... }:

{

  # --- LOGICIELS SPECIFIQUES ---
  environment.systemPackages = with pkgs; [
    kiwix
    llama-cpp-vulkan
    librecad
    krita # spécifique
    kdenlive # spécifique
    virt-manager # préférer peut-être en flatpak pour éviter les services et modules système
    qemu # préférer peut-être en flatpak pour éviter les services et modules système
    libreoffice-qt-fresh # attention, beaucoup de dépendances
    hunspell # pour libreoffice
    hunspellDicts.fr-classique # pour libreoffice
    hunspellDicts.fr-reforme1990 # pour libreoffice
    hunspellDicts.fr-moderne # pour libreoffice
    hunspellDicts.fr-any # pour libreoffice
    warzone2100 # :)
    # heroic # C'est l'un des rares cas où le Flatpak est souvent recommandé par la communauté NixOS. Comme Heroic gère des jeux provenant de magasins qui ne supportent pas Linux nativement (Epic/GOG), l'isolation Flatpak fournit un environnement plus "standard" que les jeux Windows apprécient.:
  ];

}
