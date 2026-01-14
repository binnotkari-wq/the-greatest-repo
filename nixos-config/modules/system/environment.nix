{ config, pkgs, lib, ... }:

{
  # --- Alias "upgrade" --- pour maintenance globale, écrire upgrade
  # dans le terminal executera ce qui suit :
  environment.interactiveShellInit = ''
    alias upgrade='
      echo "🚀 Début de la mise à jour globale..."

      # 1. Mise à jour des dépôts (Flake)
      cd ~/nixos-config && nix flake update

      # 2. Application de la configuration NixOS
      sudo nixos-rebuild switch --flake ~/nixos-config#dell_5485

      # 3. Mise à jour des Flatpaks
      if command -v flatpak > /dev/null; then
        echo "📦 Mise à jour des Flatpaks..."
        flatpak update -y
      fi

      # 4. Nettoyage des vieux liens morts
      echo "🧹 Nettoyage du store..."
      nix-collect-garbage --delete-older-than 7d

      echo "✅ Système à jour et nettoyé !"'
  '';
}
