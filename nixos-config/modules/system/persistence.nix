{ config, pkgs, ... }:

{
  # On utilise le sous-volume /nix (déjà persistant) pour stocker 
  # les rares fichiers système rescapés de /etc.
  # si /home et /var ne sont pas sur des partions ou des sous-volumes btrfs disincts,
  # il faudra les ajouter à la liste.
  environment.persistence."/nix/persist" = {
    # hideMounts = true; pour cacher les montages fictifs, mais utilise x-gvfs-hide, pas pertinent quand on a KDE
    directories = [
      "/etc/NetworkManager/system-connections" # Wi-Fi
    ];
    files = [
      # "/etc/machine-id" # Identité unique du PC. Pas besoin de le rendre persistant, puisqu'on la déclaré dans le .nix system
      # "/etc/adjtime"    # Heure BIOS/Système, pas vraiment besoin, se met à jour à chaque connection à internet
    ];
  };
}
