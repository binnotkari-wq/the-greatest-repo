#!/usr/bin/env bash
set -e

# --- SAISIE DES VARIABLES ---

NIXOS_VERSION="25.11" # version de Nixos à installer. La version doit correspondre à celle indiquée dans ./flake.nix  et ./users/nom_de_l'utilisateur_home.nix ainsi qu'à celle de l'environnement live d'installation (donné par nixos-version | cut -d'.' -f1,2)
DISK="nvme0n1" # disque choisi parmis la liste donnée par lsblk -dn -o NAME,SIZE,MODEL
TARGET_HOSTNAME="vm" # doit exister en tant que machine dans flake.nix et avoir un fichier tuning.nix dans ./hosts/nom_de_la_machine
TARGET_USER="benoit" # doit exister en tant qu'utilisateur dans flake.nix et avoir un fichier nom_de_l'utilisateur.nix et nom_de_l'utilisateur_home.nix dans ./users

# 5. les valeurs de ces variables n'ont pas de raison d'être différentes. Laisser tel quel.
REPO_PATH="/mnt/home/$TARGET_USER/Mes-Donnees/Git/nixos-config"


# --- RAPPEL DES SELECTIONS ---
echo ""
echo -e "\e[36m==========================================================\e[0m"
echo "L'installation sera réalisée avec les paramètres suivants :"
echo "  - Machine : $TARGET_HOSTNAME"
echo "  - Utilisateur : $TARGET_USER"
echo "  - Version de Nixos : $NIXOS_VERSION"
echo "  - Disque : /dev/$DISK"
echo "Bootstrap.sh à éditer pour adapter ces paramètres :"
echo -e "\e[36m==========================================================\e[0m"
echo -e "\n\e[31m[ATTENTION]\e[0m TOUTES LES DONNÉES SUR /dev/$DISK VONT ÊTRE EFFACÉES."
read -p "Confirmer que ces paramètres sont OK et lancer l'installation ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi


# --- DÉBUT DU SCRIPT DE PARTITIONNEMENT ---

# 1. TABLE DE PARTITIONS
echo "🏗️  Création de la table de partition GPT..."
sudo sgdisk --zap-all /dev/$DISK
sudo sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" /dev/$DISK   # EFI
sudo sgdisk -n 2:0:0      -t 2:8300 -c 2:"SYSTEM" /dev/$DISK # LUKS + BTRFS

# Gestion intelligente des noms de partitions (nvme vs autres)
if [[ $DISK == *"nvme"* || $DISK == *"mmcblk"* ]]; then
    PART_BOOT="/dev/${DISK}p1"
    PART_LUKS="/dev/${DISK}p2"
else
    PART_BOOT="/dev/${DISK}1"
    PART_LUKS="/dev/${DISK}2"
fi

# 2. CHIFFREMENT LUKS2
echo "🔐 Chiffrement de la partition système (LUKS2)..."
# On utilise les réglages standards robustes
sudo cryptsetup luksFormat --type luks2 $PART_LUKS
echo "🔓 Ouverture du conteneur chiffré..."
sudo cryptsetup open $PART_LUKS cryptroot
PART_BTRFS="/dev/mapper/cryptroot"
echo "Veuillez copier l'UUID de la partion chiffrée dans ./hosts/$TARGET_HOSTNAME/tuning.nix, partie /dev/disk/by-uuid/REPLACE_ME_LUKS_UUID"
blkid -s UUID -o value $PART_LUKS
read -p "Confirmer que l'UUID a bien été renseigné ? (y/N) : " CONFIRM

if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi

# 3. FORMATAGE
echo "🧹 Formatage des partitions..."
sudo mkfs.vfat -F 32 -n BOOT $PART_BOOT
sudo mkfs.btrfs -f -L NIXOS $PART_BTRFS

# 4. CRÉATION DES SOUS-VOLUMES BTRFS
echo "📦 Création des sous-volumes..."
sudo mount $PART_BTRFS /mnt
sudo btrfs subvolume create /mnt/@nix
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@swap
sudo umount /mnt

# 5. ARCHITECTURE STATELESS (RAM)
echo "🧠 Montage du Root en RAM..."
sudo mount -t tmpfs none /mnt -o size=2G,mode=755
sudo mkdir -p /mnt/{boot,nix,home,swap}

# 7. MONTAGES FINAUX
echo "🔗 Montages des volumes..."
sudo mount $PART_BOOT /mnt/boot
sudo mount $PART_BTRFS /mnt/nix -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS /mnt/home -o subvol=@home,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS /mnt/swap -o subvol=@swap,noatime,ssd # Pas de compression sur le swap, pas de trim (discard=async) car vu le contenu changeant du swapfile, il y aurait un trim constant
# NB : l'autorisation du trim des données avant leur chiffrement par LUKS est déclarée dans les .nix

# 8. CRÉATION DU SWAPFILE (Méthode moderne Btrfs)
echo "💾 Création du swapfile de 4Go..."
sudo btrfs filesystem mkswapfile --size 4g /mnt/swap/swapfile
sudo swapon /mnt/swap/swapfile

# 9. GÉNÉRATION DU MATÉRIEL
echo "🔍 Détection des composants matériels...sauf les sytèmes de fichier, qui vont être gérés par un .nix distinct"
sudo nixos-generate-config --root /mnt --no-filesystems

# 10. PRÉPARATION DU HOME & REPO
echo "📂 Copie de la configuration..."
sudo mkdir -p $(dirname $REPO_PATH) # on créé le dossier qui va acceuillir les fichiers .nix (c'est toujours là que je les met quel que soit le pc)
sudo mkdir -p $REPO_PATH/hosts/$TARGET_HOSTNAME # on créé le dossier spécifique avec le nom de la config correspondante dans flake.nix
sudo cp -ra . $REPO_PATH # on copie tout le contenu du dossier ou se trouve le script, c'est à dire tous les fichiers nix
sudo cp /mnt/etc/nixos/hardware-configuration.nix $REPO_PATH/hosts/$TARGET_HOSTNAME/hardware-configuration.nix ## Copier le fichier fraîchement généré vers ton dossier Git
echo "Fichiers .nix mis en place dans $REPO_PATH/"

# Droits utilisateur sur /mnt/home/$TARGET_USER et initialisation git du repo local
sudo chown -R 1000:1000 "/mnt/home/$TARGET_USER" # On donne les droits pour le futur système
cd "$REPO_PATH"
sudo git init # On utilise sudo pour les commandes git dans le script pour passer outre les protections de sécurité du live USB
sudo git add . # On utilise sudo pour les commandes git dans le script pour passer outre les protections de sécurité du live USB
sudo chown -R 1000:1000 "$REPO_PATH" # On remet un petit coup de chown au cas où le dossier .git ait été créé en root

# 11. INSTALLATION
echo "❄️  Déploiement du système...sudo nixos-install --flake $REPO_PATH#$TARGET_HOSTNAME"
read -p "Confirmer le déploiement ? (y/N) : " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "❌ Installation annulée."
    exit 1
fi
sudo nixos-install --flake $REPO_PATH#$TARGET_HOSTNAME
echo "✅ Installation terminée avec succès !"
echo "🚀 Vous pouvez redémarrer."
