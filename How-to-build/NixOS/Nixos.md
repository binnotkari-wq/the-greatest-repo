Nixos
========================
# Touchpad X240 A DEFINIR
sous wayland, libinput

--> je me rend compte que les boutons clic gauche et droit sont reconnu, il faut se mettre de part et d'autre de petit repere sur le touchpad. Mais est-ce que c'est du fait des modifs faites sur conseils de gemini ? ou est ce que c'etait deja comme ca ? A voir en rebootant que la premiere itération, voir si ca marche quand tout est d'origine.


# Secure boot A DEFINIR
Il faut booter avec Limine
https://wiki.nixos.org/wiki/Limine


En plus de Lanzaboote, le module NixOS Limine a récemment obtenu le support Secure Boot](https://search.nixos.org/options?channel=unstable&show=boot.loader.limine.secureBoot.enable&query=boot.loader.limine.secureBoot.enable) aussi. 


# Environnement flatpak (OK)


## Activer flatpaks

 Ajouter dans /etc/nixos/configuration.nix :
 
 
  ```bash
  services.flatpak.enable = true;
  ```
 
 Puis dans le terminal :
 ```bash
 sudo nixos-rebuild switch
 ```

## Installation des flatpaks uniquement dans le dossier utilisateur

 ```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo --user
flatpak remote-delete --system flathub
 ```
 
 
 
 # Environnement appimage
 
 ## Activer la prise en charge d'AppImage
 
  ```bash
  programs.appimage = {
    enable = true;                 # Activer l'intégration AppImage
    binfmt = true;                 # Activer la prise en charge du format binaire AppImage
  };
   ```