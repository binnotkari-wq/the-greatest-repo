#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE DÉPLOIEMENT NIXOS (Architecture Stateless / Root-on-RAM)
# Cible : dell_5485
# ==============================================================================

set -e # Stop sur erreur

# --- CONFIGURATION ---
DISK="/dev/nvme0n1p3"     # Partition Btrfs
PART_BOOT="/dev/nvme0n1p1" # Partition EFI
USER_NAME="benoit"
FLAKE_NAME="dell_5485"
TARGET="/mnt"

echo "🚀 Début de la préparation du système..."

# 1. Nettoyage et montage temporaire du disque physique
sudo umount -R $TARGET 2>/dev/null || true
sudo mount $DISK $TARGET

# 2. Création des sous-volumes Btrfs (Persistance SSD)
echo "📦 Création des sous-volumes..."
# On vérifie s'ils existent déjà pour éviter les erreurs
sudo btrfs subvolume create $TARGET/@nix || echo "Subvol @nix existe déjà"
sudo btrfs subvolume create $TARGET/@home || echo "Subvol @home existe déjà"

sudo umount $TARGET

# 3. Mise en place de l'architecture RAM (Stateless)
echo "🧠 Configuration du Root en RAM (tmpfs)..."
sudo mount -t tmpfs none $TARGET -o size=2G,mode=755

# 4. Création de l'arborescence et montage des volumes réels
echo "🔗 Montage des partitions..."
sudo mkdir -p $TARGET/{nix,home,boot}

sudo mount $DISK $TARGET/nix -o subvol=@nix,noatime,compress=zstd
sudo mount $DISK $TARGET/home -o subvol=@home,compress=zstd
sudo mount $PART_BOOT $TARGET/boot

# 5. Injection de la configuration dans le nouveau Home
echo "📂 Pré-positionnement du dépôt Git..."
REPO_PATH="$TARGET/home/$USER_NAME/Mes-Donnees/Git/nixos-config"
sudo mkdir -p $(dirname $REPO_PATH)
sudo cp -ra . $REPO_PATH

# Ajustement des permissions pour ton utilisateur (UID 1000)
sudo chown -R 1000:1000 $TARGET/home/$USER_NAME

# 6. Lancement de l'installation
echo "❄️ Lancement de nixos-install..."
echo "Le mot de passe root sera celui défini par ton hash dans la config."
sudo nixos-install --flake $REPO_PATH#$FLAKE_NAME

echo "✅ Terminé ! Tu peux taper 'reboot'."
