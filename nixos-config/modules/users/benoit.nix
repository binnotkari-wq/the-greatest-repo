{ pkgs, ... }:

{
  users.users.benoit = {
    isNormalUser = true;
    description = "Benoit";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
    hashedPassword = "$y$j9T$Mj35eRqiQeZAF3qCODbuX0$x/QwgdyVj5QmuglgOkukZfb5n/SsLklBn.ipr.gy1YC";
    # Tu peux même déjà ajouter des packages spécifiques à cet utilisateur ici
    packages = with pkgs; [
    #  firefox
    #  mangohud
    ];
  };
}
