  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # You can use https://search.nixos.org/ to find more packages (and options).

{ config, pkgs, ... }:

{
  # Logiciels à installer
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

  #Logiciels à supprimer
  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.kate
    kdePackages.discover
  ];
}
