{ config, pkgs, ... }:

{
  # On utilise le sous-volume /nix (déjà persistant) pour stocker 
  # les rares fichiers système rescapés de /etc.
  # si /home et /var ne sont pas sur des partions ou des sous-volumes btrfs disincts,
  # il faudra à la liste leur éléments à persister.
  environment.persistence."/nix/persist" = {
    # hideMounts = true; pour cacher les montages fictifs, mais utilise x-gvfs-hide, pas pertinent quand on a KDE
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/nixos"
      "/var/lib/cups"
      "/var/lib/fwupd"
    ];
    files = [
      "/etc/machine-id" # Identité unique du PC.
      # "/etc/adjtime"    # Heure BIOS/Système, pas vraiment besoin, se met à jour à chaque connection à internet
    ];
  };
}
