#!/usr/bin/env bash
set -e

# --- SAISIE INTERACTIVE DES VARIABLES ---
echo "--- Configuration de l'installation NixOS ---"
echo

# 1. Choix de la version de NixOS
# Détection automatique pour information
LIVE_VERSION=$(nixos-version | cut -d'.' -f1,2)

echo -e "\n\e[36m=== Contrôle de la version NixOS ===\e[0m"
echo -e "Version détectée sur le Live USB : \e[33m$LIVE_VERSION\e[0m"

while true; do
    echo -ne "\nVeuillez confirmer le numéro de version à installer (ex: $LIVE_VERSION) : "
    read INPUT_VERSION

    if [ "$INPUT_VERSION" == "$LIVE_VERSION" ]; then
        NIXOS_VERSION=$INPUT_VERSION
        echo -e "\e[32m[OK]\e[0m Version $NIXOS_VERSION validée pour l'injection dans flake.nix et ."
        break
    else
        echo -e "\e[31m[ERREUR]\e[0m La version saisie ($INPUT_VERSION) ne correspond pas au Live USB ($LIVE_VERSION)."
        echo "L'installation doit se faire sur la même version pour garantir la stabilité."
    fi
done


# 2. Choix du disque ---
echo -e "\n\e[36m=== Liste des disques physiques détectés ===\e[0m"
# On liste les disques avec leur taille et modèle pour aider au choix
lsblk -dn -o NAME,SIZE,MODEL
echo -e "\e[36m============================================\e[0m"

DEFAULT_DISK="nvme0n1"

while true; do
    echo -ne "\nChoix du disque cible [\e[33m$DEFAULT_DISK\e[0m] : "
    read DISK
    DISK=${DISK:-$DEFAULT_DISK}

    # Vérification : est-ce que le disque existe dans /dev/ ?
    if [ -b "/dev/$DISK" ]; then
        echo -e "\e[32m[OK]\e[0m Le disque /dev/$DISK est valide."

        # Double confirmation visuelle car c'est une opération destructive
        echo -e "\n\e[31m[ATTENTION]\e[0m TOUTES LES DONNÉES SUR /dev/$DISK VONT ÊTRE EFFACÉES."
        echo -ne "Confirmez le nom du disque pour continuer : "
        read CONFIRM_DISK

        if [ "$DISK" == "$CONFIRM_DISK" ]; then
            echo -e "\e[32m[CONFIRMÉ]\e[0m Disque /dev/$DISK séléctionné..."
            break
        else
            echo -e "\e[31m[ERREUR]\e[0m La confirmation ne correspond pas. On recommence."
        fi
    else
        echo -e "\e[31m[ERREUR]\e[0m Le périphérique /dev/$DISK n'existe pas. Vérifiez le nom (ex: sda, nvme0n1)."
    fi
done


# 3. Choix de la machine ---
echo -e "\n\e[36m=== Liste des configurations disponibles dans le Flake ===\e[0m"
# On extrait les noms des configurations (entre guillemets) dans le bloc nixosConfigurations
grep -oP '(?<=")[^"]+(?=" = nixpkgs.lib.nixosSystem)' flake.nix
echo -e "\e[36m==========================================================\e[0m"

while true; do
    echo -ne "\nEntrez le nom exact de la machine à installer (ex: dell-5485) : "
    read TARGET_HOSTNAME

    # Vérification si le nom saisi existe bien dans le flake.nix
    if grep -q "\"$TARGET_HOSTNAME\" = nixpkgs.lib.nixosSystem" flake.nix; then
        echo -e "\e[32m[OK]\e[0m Configuration '$TARGET_HOSTNAME' validée."
        break
    else
        echo -e "\e[31m[ERREUR]\e[0m La machine '$TARGET_HOSTNAME' n'existe pas dans le flake.nix. Réessayez."
    fi
done


# 4. Choix de l'utilisateur ---
echo -e "\n\e[36m=== Utilisateurs système détectés (./users/*.nix) ===\e[0m"
# On liste les fichiers .nix, on enlève le chemin et l'extension .nix
# On exclut "benoit_home.nix" ou tout fichier contenant "home" pour ne lister que les comptes système
ls ./users/*.nix | grep -v "home" | xargs -n 1 basename | sed 's/\.nix//'
echo -e "\e[36m=====================================================\e[0m"

while true; do
    echo -ne "\nEntrez le nom de l'utilisateur à configurer : "
    read TARGET_USER

    # On vérifie si le fichier ./users/$TARGET_USER.nix existe bien
    if [ -f "./users/$TARGET_USER.nix" ]; then
        echo -e "\e[32m[OK]\e[0m Utilisateur '$TARGET_USER' validé (fichier trouvé)."
        break
    else
        echo -e "\e[31m[ERREUR]\e[0m L'utilisateur '$TARGET_USER n'a pas de .nix dans ./users/. Réessayez."
    fi
done

# Optionnel : On vérifie juste si le fichier home_benoit.nix (ou autre) existe aussi
if [ -f "./users/${TARGET_USER}_home.nix" ]; then
    echo -e "\e[34m[INFO]\e[0m Configuration Home Manager '${TARGET_USER}_home.nix' détectée."
fi


# 5. les valeurs de ces variables n'ont pas de raison d'être différentes. Laisser tel quel.
TARGET_MOUNT="/mnt"
REPO_PATH="$TARGET_MOUNT/home/$TARGET_USER/Mes-Donnees/Git/nixos-config"


# --- RAPPEL DES SELECTIONS ---
echo ""
echo -e "\e[36m==========================================================\e[0m"
echo "RÉCAPITULATIF DE L'INSTALLATION :"
echo "  - Machine : $TARGET_HOSTNAME"
echo "  - Utilisateur : $TARGET_USER"
echo "  - Version de Nixos : $NIXOS_VERSION"
echo "  - Disque : /dev/$DISK"
echo -e "\e[36m==========================================================\e[0m"
echo -e "\n\e[31m[ATTENTION]\e[0m TOUTES LES DONNÉES SUR /dev/$DISK VONT ÊTRE EFFACÉES."
read -p "Confirmer l'effacement et lancer l'installation ? (y/N) : " CONFIRM

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

# 3. FORMATAGE
echo "🧹 Formatage des partitions..."
sudo mkfs.vfat -F 32 -n BOOT $PART_BOOT
sudo mkfs.btrfs -f -L NIXOS $PART_BTRFS

# 4. CRÉATION DES SOUS-VOLUMES BTRFS
echo "📦 Création des sous-volumes..."
sudo mount $PART_BTRFS $TARGET_MOUNT
sudo btrfs subvolume create $TARGET_MOUNT/@nix
sudo btrfs subvolume create $TARGET_MOUNT/@home
sudo btrfs subvolume create $TARGET_MOUNT/@swap
sudo umount $TARGET_MOUNT

# 5. ARCHITECTURE STATELESS (RAM)
echo "🧠 Montage du Root en RAM..."
sudo mount -t tmpfs none $TARGET_MOUNT -o size=2G,mode=755
sudo mkdir -p $TARGET_MOUNT/{boot,nix,home,swap}

# 7. MONTAGES FINAUX
echo "🔗 Montages des volumes..."
sudo mount $PART_BOOT $TARGET_MOUNT/boot
sudo mount $PART_BTRFS $TARGET_MOUNT/nix -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/home -o subvol=@home,noatime,compress=zstd,ssd,discard=async
sudo mount $PART_BTRFS $TARGET_MOUNT/swap -o subvol=@swap,noatime,ssd # Pas de compression sur le swap, pas de trim (discard=async) car vu le contenu changeant du swapfile, il y aurait un trim constant
# NB : l'autorisation du trim des données avant leur chiffrement par LUKS est déclarée dans les .nix

# 8. CRÉATION DU SWAPFILE (Méthode moderne Btrfs)
echo "💾 Création du swapfile de 4Go..."
sudo btrfs filesystem mkswapfile --size 4g $TARGET_MOUNT/swap/swapfile
sudo swapon $TARGET_MOUNT/swap/swapfile

# 9. GÉNÉRATION DU MATÉRIEL
echo "🔍 Détection des composants matériels...sauf les sytèmes de fichier, qui vont être gérés par un .nix distinct"
sudo nixos-generate-config --root $TARGET_MOUNT --no-filesystems

# 10. CAPTURE DE L'UUID LUKS2 ---
echo "🆔 Récupération de l'UUID LUKS..."
REAL_UUID=$(blkid -s UUID -o value $PART_LUKS)

# 10. PRÉPARATION DU HOME & REPO
echo "📂 Copie de la configuration..."
sudo mkdir -p $(dirname $REPO_PATH) # on créé le dossier qui va acceuillir les fichiers .nix (c'est toujours là que je les met quel que soit le pc)
sudo mkdir -p $REPO_PATH/hosts/$TARGET_HOSTNAME # on créé le dossier spécifique avec le nom de la config correspondante dans flake.nix
sudo cp -ra . $REPO_PATH # on copie tout le contenu du dossier ou se trouve le script, c'est à dire tous les fichiers nix
sudo cp $TARGET_MOUNT/etc/nixos/hardware-configuration.nix $REPO_PATH/hosts/$TARGET_HOSTNAME/hardware-configuration.nix ## Copier le fichier fraîchement généré vers ton dossier Git
echo "Fichiers .nix mis en place dans $REPO_PATH/"


# Mise à jour du flake.nix avec le numéro de version NixOS à installer
sudo sed -i "s/nixos-[0-9]\{2\}\.[0-9]\{2\}/nixos-$NIXOS_VERSION/g" "$REPO_PATH/flake.nix"
sudo sed -i "s/release-[0-9]\{2\}\.[0-9]\{2\}/release-$NIXOS_VERSION/g" "$REPO_PATH/flake.nix"
sudo sed -i "s/system\.stateVersion = \"[0-9]\{2\}\.[0-9]\{2\}\"/system\.stateVersion = \"$NIXOS_VERSION\"/g" "$REPO_PATH/flake.nix"
sudo sed -i "s/home\.stateVersion = \"[0-9]\{2\}\.[0-9]\{2\}\"/home\.stateVersion = \"$NIXOS_VERSION\"/g" "$REPO_PATH/users/${TARGET_USER}_home.nix"

# Injection de l'UUID LUKS2 dans le fichier .nix spécifique à la machine
sudo sed -i "s|by-uuid/[^\"]*|by-uuid/$REAL_UUID|g" "$REPO_PATH/hosts/$TARGET_HOSTNAME/tuning.nix"

# Droits utilisateur sur $TARGET_MOUNT/home/$TARGET_USER et git du repo local
sudo chown -R 1000:1000 "$TARGET_MOUNT/home/$TARGET_USER" # On donne les droits pour le futur système
cd "$REPO_PATH"
sudo git init # On utilise sudo pour les commandes git dans le script pour passer outre les protections de sécurité du live USB
sudo git add . # On utilise sudo pour les commandes git dans le script pour passer outre les protections de sécurité du live USB
sudo chown -R 1000:1000 "$REPO_PATH" # On remet un petit coup de chown au cas où le dossier .git ait été créé en root


# 11. INSTALLATION
echo "❄️  Déploiement du système...sudo nixos-install --flake $REPO_PATH#$TARGET_HOSTNAME"
read -p "Confirmer ? (y/N) : " CONFIRM
sudo nixos-install --flake $REPO_PATH#$TARGET_HOSTNAME

echo "✅ Installation terminée avec succès !"
echo "🚀 Vous pouvez redémarrer."

echo "Point à verifier :"
echo "- le numéro de version de NixOS dans $REPO_PATH/flake.nix"
echo "- le numéro de version de NixOS dans $REPO_PATH/users/${TARGET_USER}_home.nix"
echo "- l'UUID LUKS2 dans $REPO_PATH/hosts/$TARGET_HOSTNAME/tuning.nix"
