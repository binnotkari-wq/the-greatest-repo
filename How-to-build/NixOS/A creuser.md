A creuser
=========

## Scripts directement en déclaratif

Puisque vous avez mentionné avoir des scripts de configuration, Home Manager vous permet de faire quelque chose de très puissant : écrire vos scripts directement en Nix et les ajouter à votre PATH.

Au lieu d'avoir un fichier .sh qui traîne, vous pouvez faire ceci dans votre home.nix :

```bash
home.packages = with pkgs; [
  wget
  pandoc
  # Exemple de script qui utilise wget et pandoc
  (writeScriptBin "convert-web-doc" ''
    #!/bin/bash
    ${wget}/bin/wget -O temp.html "$1"
    ${pandoc}/bin/pandoc temp.html -o output.pdf
    rm temp.html
  '')
];
```

## https://wiki.nixos.org/wiki/Steam

### Steam

```bash
programs.steam = {
  enable = true;
};


# Tip: For improved gaming performance, you can also enable GameMode:
# programs.gamemode.enable = true;
```



### Gamescope Compositor / "Boot to Steam Deck"

Gamescope can function as a minimal desktop environment, meaning you can launch it from a TTY and have an experience very similar to the Steam Deck hardware console.

```bash
# Clean Quiet Boot
boot.kernelParams = [ "quiet" "splash" "console=/dev/null" ];
boot.plymouth.enable = true;

programs.gamescope = {
  enable = true;
  capSysNice = true;
};
programs.steam.gamescopeSession.enable = true; # Integrates with programs.steam

# Gamescope Auto Boot from TTY (example)
services.xserver.enable = false; # Assuming no other Xserver needed
services.getty.autologinUser = "USERNAME_HERE";

services.greetd = {
  enable = true;
  settings = {
    default_session = {
      command = "${pkgs.gamescope}/bin/gamescope -W 1920 -H 1080 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
      user = "USERNAME_HERE";
    };
  };
};
```



## https://github.com/Gaming-Linux-FR/GLF-OS/blob/testing/modules/default/boot.nix


```bash
    hardware.graphics = {
      enable = true;
      package = pkgs.mesa;
      package32 = pkgs.pkgsi686Linux.mesa;
    };
```


## https://github.com/Gaming-Linux-FR/GLF-OS/blob/testing/modules/default/gaming.nix
    
```bash
programs.gamemode.enable = true;

    
    # Gamescope configuration
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    
    # Steam configuration
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = if config.glf.mangohud.configuration == "light" || config.glf.mangohud.configuration == "full" then
            true
          else
            false;
          OBS_VKCAPTURE = true;
        };
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };
    
```   