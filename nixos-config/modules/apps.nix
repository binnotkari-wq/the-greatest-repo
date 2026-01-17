  # List packages installed in system profile. To search, run:

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Logiciels en CLI
    wget
    git
    pandoc
    pkgs.llama-cpp-vulkan

    # Utilitaires officiels KDE
    kdePackages.filelight
    pkgs.kdePackages.kdialog
    pkgs.kdePackages.kde-cli-tools
    pkgs.kdePackages.kdeconnect-kde
  ];

  #Logiciels à supprimer du lot de base de KDE
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.kate
    kdePackages.discover
  ];
}
