#!/usr/bin/env bash
set -e

# --- SAISIE INTERACTIVE DES VARIABLES ---
echo "--- Configuration de l'installation NixOS ---"

# 1. Choix du disque
DEFAULT_DISK="/dev/nvme0n1"
read -p "Disque cible [$DEFAULT_DISK] : " DISK
DISK=${DISK:-$DEFAULT_DISK}

# 2. Choix de l'utilisateur
DEFAULT_USER="benoit"
read -p "Nom d'utilisateur [$DEFAULT_USER] : " USER_NAME
USER_NAME=${USER_NAME:-$DEFAULT_USER}

# 3. Choix du nom de la machine (miniscules_sans_espaces)
DEFAULT_FLAKE="dell_5485"
read -p "Nom de la config dans le flake [$DEFAULT_FLAKE] : " FLAKE_NAME
FLAKE_NAME=${FLAKE_NAME:-$DEFAULT_FLAKE}

TARGET="/mnt"

echo ""
echo "-------------------------------------------------------"
echo "RÉCAPITULATIF DE L'INSTALLATION :"
echo "  - Disque : $DISK"
echo "  - Utilisateur : $USER_NAME"
echo "  - Configuration Flake : $FLAKE_NAME"
echo "-------------------------------------------------------"
echo "⚠️  ATTENTION : Tout le contenu de $DISK va être effacé !"
read -p "Confirmer l'effacement et lancer l'installation ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi

# --- DÉBUT DU SCRIPT DE PARTITIONNEMENT ---

echo "🏗️  Création de la table de partition GPT..."
sudo sgdisk --zap-all $DISK
sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" $DISK   # EFI
sudo sgdisk -n 2:0:+8G    -t 2:8200 -c 2:"SWAP" $DISK   # SWAP
sudo sgdisk -n 3:0:0       -t 3:8300 -c 3:"SYSTEM" $DISK # BTRFS

# Gestion intelligente des noms de partitions (nvme0n1p1 vs sda1)
PART_BOOT="${DISK}1"
PART_SWAP="${DISK}2"
PART_BTRFS="${DISK}3"

if [[ $DISK == *"nvme"* || $DISK == *"mmcblk"* ]]; then
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

# 6. PRÉPARATION DU HOME & REPO
echo "📂 Copie de la configuration..."
REPO_PATH="$TARGET/home/$USER_NAME/Mes-Donnees/Git/nixos-config"
sudo mkdir -p $(dirname $REPO_PATH)
sudo cp -ra . $REPO_PATH
sudo chown -R 1000:1000 $TARGET/home/$USER_NAME

# 7. INSTALLATION
echo "❄️  Lancement de nixos-install..."
sudo nixos-install --flake $REPO_PATH#$FLAKE_NAME

echo "✅ Terminé ! Tu peux redémarrer."
