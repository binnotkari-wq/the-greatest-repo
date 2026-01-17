#!/usr/bin/env bash
set -e

# --- CONFIGURATION (À adapter selon la VM ou le PC) ---
# En VM, c'est souvent /dev/vda ou /dev/sda. Sur ton Dell, c'est /dev/nvme0n1
DISK="/dev/sda"
USER_NAME="benoit"
FLAKE_NAME="dell_5485"
TARGET="/mnt"

echo "⚠️ ATTENTION : Tout le contenu de $DISK va être effacé !"
sleep 5 # petite pause pour réfléchir

# 1. PARTITIONNEMENT (GPT)
echo "🏗️ Création de la table de partition GPT..."
sudo sgdisk --zap-all $DISK
sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" $DISK   # EFI
sudo sgdisk -n 2:0:+8G    -t 2:8200 -c 2:"SWAP" $DISK   # SWAP
sudo sgdisk -n 3:0:0       -t 3:8300 -c 3:"SYSTEM" $DISK # BTRFS

# On définit les variables de partitions
PART_BOOT="${DISK}1"
PART_SWAP="${DISK}2"
PART_BTRFS="${DISK}3"

# Note pour les disques NVMe : les partitions s'appellent p1, p2, p3
if [[ $DISK == *"nvme"* ]]; then
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
echo "❄️ Lancement de nixos-install..."
sudo nixos-install --flake $REPO_PATH#$FLAKE_NAME

echo "✅ Terminé ! Tu peux redémarrer."
