Rollback et gestion des générations
========================
https://www.linuxtricks.fr/wiki/nixos-gestion-des-generations-rollback-suppression-menage


## Rollback sur une base saine

1. Choix de la génération saine

Lister les générations :

```bash
nixos-rebuild list-generations
```
Et identifier dans la liste une génération convenable.

2. Marquage comme base officielle

On marque cette génération comme génération officielle (ici, la numéro 7) :

```bash
sudo nix-env --profile /nix/var/nix/profiles/system --switch-generation 7
```

3. Basculer sur cette génération

On peut valider la bascule sans redémarrer via la commande :

```bash
/nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

4. Reboot sur la génération

Redémarrer le pc en sélectionnant la génération souhaitée dans le gestionnaire de démarrage.

## Rebuild propre depuis base saine

Nettoyer les .nix pour qu'ils correspondent vraiment à la config souhaitée, et rebuilder. Ce qui permettra d'avoir comme génération officielle, la plus récente.

4. Rebuilder

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#dell_5485
reboot

```

5. Faire un commit des fichiers .nix

```bash
cd ~/nixos-config
git add .
git commit -m "retour à config propre, abandon modifs gaming"
git push
```

## Suppression générations obsolètes

1. Choix des générations obsolètes 

Lister les générations :

```bash
nixos-rebuild list-generations
```
Et identifier dans la liste les générations obsolètes.

2. Purge de ces génération

Si les générations 1,2,3,4 et 5 sont celles à supprimer : 

```bash
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 1 2 3 5
sudo nix-collect-garbage
```

3. Mise à jour liste générations du bootloader 

Refaire une génération pour mettre à jour le bootloader :

```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#dell_5485
```