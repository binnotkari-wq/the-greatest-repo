{ pkgs, ... }:

let
# On définit la session avec les métadonnées exigées par NixOS
  steam-custom-session = pkgs.runCommand "steam-custom-session" {
    passthru.providedSessions = [ "steam-custom" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat <<EOF > $out/share/wayland-sessions/steam-custom.desktop
    [Desktop Entry]
    Name=Steam Custom (Bluetooth+Perfs)
    Comment=Steam (Gamescope et MangoHud)
    Exec=${pkgs.gamescope}/bin/gamescope --mangoapp -e -- ${pkgs.steam}/bin/steam -steamdeck -steamos3 -gamepadui
    Type=Application
    DesktopNames=gamescope
    EOF
  '';
in

{
  # 1. On dit à SDDM de charger cette session spécifique
  services.displayManager.sessionPackages = [ steam-custom-session ];

  # 2. Le reste de ta config Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = false; # on utilise la session custom à la place

    extraPackages = with pkgs; [
      mangohud # Pour s'assurer que les libs sont là
    ];
  };


  # 2. On active GameMode (toujours utile)
  programs.gamemode.enable = true;

  # 3. On ajoute juste MangoHud pour les stats en jeu
  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
  ];
}
