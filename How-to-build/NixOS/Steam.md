Steam
========================

## Solution flatpaks :

```bash
flatpak install --user com.valvesoftware.Steam
flatpak install --user org.freedesktop.Platform.VulkanLayer.MangoHud
flatpak install --user org.freedesktop.Platform.VulkanLayer.gamescope
```

Argument de la ligne de commande du raccourci menu KDE :
```bash
run --branch=stable --arch=x86_64 --command=/app/bin/steam --file-forwarding com.valvesoftware.Steam -steamos3 -steamdeck -gamepadui @@u %U @@n
```



Le bluetooth n'est pas géré directement depuis steam flatpak : il faut associer la manette depuis KDE




Si steam est installé déclarativement dans Nixos,

MangoHud, :  n'oublie pas que pour l'activer dans un jeu Steam, tu devras ajouter ceci dans les "Options de lancement" du jeu dans Steam : mangohud %command%

Si tu veux que GameMode s'active aussi en même temps, ce sera : gamemoderun mangohud %command%