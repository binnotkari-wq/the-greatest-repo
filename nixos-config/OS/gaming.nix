{ pkgs, ... }:

{
  # 1. On active Steam et sa session Gamescope intégrée
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  # 2. On active GameMode (toujours utile)
  programs.gamemode.enable = true;

  # 3. On ajoute juste MangoHud pour les stats en jeu
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
