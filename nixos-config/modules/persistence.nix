{ config, pkgs, ... }:

{
  # On utilise le sous-volume /nix (déjà persistant) pour stocker les rares fichiers système rescapés de /etc et /var.
  # Si /home n'est pas sur une partion ou des sous-volume btrfs disincts, il faut le lister ici.
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
      # "/home"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
    ];
  };
}
