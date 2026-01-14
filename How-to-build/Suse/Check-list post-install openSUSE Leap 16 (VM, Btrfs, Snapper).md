Check-list post-install openSUSE Leap 16 (VM, Btrfs, Snapper)
========================


0️⃣ État initial attendu (avant toute action)

Vérifie une seule fois :

findmnt /


✅ attendu :

/ → /dev/mapper/...[/@]


❌ à éviter :

/@/.snapshots/X/snapshot


👉 Si tu es dans un snapshot → snapper rollback avant de continuer.

1️⃣ Mise à jour propre (première transaction)

Toujours commencer par une transaction système proprement tracée :

sudo zypper refresh
sudo zypper update


✔️ openSUSE crée automatiquement :

snapshot pre

snapshot post

2️⃣ Vérifier Snapper (sans toucher)
sudo snapper list


Tu dois voir :

snapshots zypp

aucun * sur un snapshot

#0 current sans étoile

👉 Ne pas créer de snapshot manuel ici.

3️⃣ Vérifier l’intégration GRUB ⇄ Snapper
rpm -q grub-btrfs grub-btrfs-progs
systemctl status grub-btrfs.path


Si besoin :

sudo zypper install grub-btrfs grub-btrfs-progs
sudo systemctl enable --now grub-btrfs.path
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

4️⃣ Forcer l’affichage du menu GRUB (VM)

Indispensable en VM.

sudo nano /etc/default/grub


Ajoute / vérifie :

GRUB_TIMEOUT=5
GRUB_TIMEOUT_STYLE=menu


Puis :

sudo grub2-mkconfig -o /boot/grub2/grub.cfg

5️⃣ Snapshot “baseline” correct

Maintenant seulement 👇

sudo snapper create --description "baseline post-install propre"


✔️ Snapshot créé
❌ Pas de bascule dessus

6️⃣ Règle d’or Snapper (à retenir)
Action	Autorisée
Installer logiciels	✅
Créer snapshot manuel	✅
Booter un snapshot	⚠️ dépannage uniquement
Travailler au quotidien dans un snapshot	❌
Rollback permanent	✅ quand validé
7️⃣ Test de rollback (optionnel mais recommandé)

Installe quelque chose :

sudo zypper install htop


Redémarre → GRUB →
Start bootloader from a read-only snapshot

Choisis le snapshot avant l’installation

Vérifie :

htop


→ doit être absent

Reviens au système normal :

sudo snapper rollback
sudo reboot

8️⃣ Nettoyage Snapper (VM)

Par défaut Snapper est trop conservateur pour une VM.

sudo nano /etc/snapper/configs/root


Ajuste par exemple :

NUMBER_LIMIT=10
NUMBER_LIMIT_IMPORTANT=5

9️⃣ Vérification finale (sanity check)
findmnt /
snapper list


✔️ /@
✔️ snapshots multiples
✔️ aucun * actif

🧠 Modèle mental à garder

Snapper = filet de sécurité transactionnel
Pas une sauvegarde continue

Snapshots :

servent à revenir

pas à vivre dedans