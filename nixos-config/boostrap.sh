#!/usr/bin/env bash
set -e

# --- SAISIE INTERACTIVE DES VARIABLES ---
echo "--- Configuration de l'installation NixOS ---"
echo
echo "Liste des disques existants :"
lsblk -d
echo

# 1. Choix du disque
DEFAULT_DISK="nvme0n1"
read -p "Choix du disque cible [$DEFAULT_DISK] : " DISK
DISK=${DISK:-$DEFAULT_DISK}

# 2. Choix de la version de NixOS
DEFAULT_VERSION="25.11"
read -p "Version de NixOS (ce doit être celle de l'environnement d'installation) [$DEFAULT_VERSION] : " NIXOS_VERSION
NIXOS_VERSION=${NIXOS_VERSION:-$DEFAULT_VERSION}

#### RESTE A DEMANDER A GEMINI DE FAIRE LA COMMANDE POUR INSERER CETTE VALEUR DANS LES .NIX


# 3. Choix du nom de la machine
DEFAULT_FLAKE="dell_5485"
read -p "Nom de la config dans le flake (miniscules_sans_espaces) [$DEFAULT_FLAKE] : " FLAKE_NAME
FLAKE_NAME=${FLAKE_NAME:-$DEFAULT_FLAKE}

#### RESTE A DEMANDER A GEMINI DE FAIRE LA COMMANDE POUR INSERER CETTE VALEUR DANS LES .NIX
#### avant cela, retrouver toutes les occurence de dell_5485 et voir si on peut regrouper tout cela dans un fichier distinct dans hosts/dell_5485, sauf l'occurence dans flake.nix


# 3. les valeurs de ces variables n'ont pas de raison d'être différentes
USER_NAME="benoit"
TARGET="/mnt"

echo ""
echo "-------------------------------------------------------"
echo "RÉCAPITULATIF DE L'INSTALLATION :"
echo "  - Disque : /dev/$DISK"
echo "  - Version de Nixos : $NIXOS_VERSION"
echo "  - Configuration Flake : $FLAKE_NAME"
echo "-------------------------------------------------------"
echo "⚠️  ATTENTION : Tout le contenu de /dev/$DISK va être effacé !"
read -p "Confirmer l'effacement et lancer l'installation ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi

# --- DÉBUT DU SCRIPT DE PARTITIONNEMENT ---

echo "🏗️  Création de la table de partition GPT..."
sudo sgdisk --zap-all /dev/$DISK
sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" /dev/$DISK   # EFI
sudo sgdisk -n 2:0:+8G    -t 2:8200 -c 2:"SWAP" /dev/$DISK   # SWAP
sudo sgdisk -n 3:0:0       -t 3:8300 -c 3:"SYSTEM" /dev/$DISK # BTRFS

# Gestion intelligente des noms de partitions (nvme0n1p1 vs sda1)
PART_BOOT="${DISK}1"
PART_SWAP="${DISK}2"
PART_BTRFS="${DISK}3"

if [[ /dev/$DISK == *"nvme"* || /dev/$DISK == *"mmcblk"* ]]; then
    PART_BOOT="${DISK}p1"
    PART_SWAP="${DISK}p2"
    PART_BTRFS="${DISK}p3"
fi

# 2. FORMATAGE
echo "🧹 Formatage des partitions..."
sudo mkfs.vfat -F 32 -n BOOT $PART_BOOT
sudo mkswap -L SWAP $PART_SWAP
sudo swapon $PART_SWAP
sudo mkfs.btrfs -f -L NIXOS $PART_BTRFS

# 3. CRÉATION DES SOUS-VOLUMES BTRFS
echo "📦 Création des sous-volumes..."
sudo mount $PART_BTRFS $TARGET
sudo btrfs subvolume create $TARGET/@nix
sudo btrfs subvolume create $TARGET/@home
sudo umount $TARGET

# 4. ARCHITECTURE STATELESS (RAM)
echo "🧠 Montage du Root en RAM..."
sudo mount -t tmpfs none $TARGET -o size=2G,mode=755
sudo mkdir -p $TARGET/{nix,home,boot}

# 5. MONTAGES FINAUX
echo "🔗 Montages des volumes..."
sudo mount $PART_BTRFS $TARGET/nix -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET/home -o subvol=@home,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BOOT $TARGET/boot

# 6. GÉNÉRATION DU MATÉRIEL
echo "🔍 Détection des composants matériels...sauf les sytèmes de fichier, qui vont être gérés par un .nix distinct"
sudo nixos-generate-config --root $TARGET --no-filesystems

# 7. PRÉPARATION DU HOME & REPO
echo "📂 Copie de la configuration..."
REPO_PATH="$TARGET/home/$USER_NAME/Mes-Donnees/Git/nixos-config"
sudo mkdir -p $(dirname $REPO_PATH) # on créé le dossier qui va acceuillir les fichiers .nix (c'est toujours là que je les met quel que soit le pc)
sudo cp -ra . $REPO_PATH # on copie tout le contenu du dossier ou se trouve le script, c'est à dire tous les fichiers nix
sudo chown -R 1000:1000 $TARGET/home/$USER_NAME

# On remplace le hardware-configuration.nix de repo git par celui généré spécifiquement pour cette machine
sudo cp $TARGET/etc/nixos/hardware-configuration.nix $REPO_PATH/hosts/$FLAKE_NAME/hardware-configuration.nix

# 7. INSTALLATION
echo "❄️  Déploiement du système..."
sudo nixos-install --flake $REPO_PATH#$FLAKE_NAME

echo "✅ Installation terminée avec succès !"
echo "🚀 Vous pouvez redémarrer."
