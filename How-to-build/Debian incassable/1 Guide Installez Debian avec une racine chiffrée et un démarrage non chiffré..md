 1 Guide : Installez Debian avec une racine chiffrée et un démarrage non chiffré.
========================

alutations!

Puisque ces informations semblent rares, Netinst peut être intimidant, et comme je ne crois pas que Linux devrait être basé sur des secrets commerciaux ou des connaissances ésotériques, voici un très bref guide sur la façon de procéder avec le CD Netinst de Debian Bookworm. " Image ISO, qui peut être téléchargée ici (la plupart des ordinateurs modernes utilisent l'architecture amd64, alors choisissez-la sauf si vous avez un cas d'utilisation particulier) :

https://www.debian.org/releases/bookworm/debian-installer/

Les raisons pour lesquelles vous souhaitez que /boot ne soit pas chiffré sont variées. Peut-être souhaitez-vous un temps de démarrage (beaucoup) plus rapide, ou peut-être souhaitez-vous utiliser un joli thème GRUB ou Plymouth, ou utilisez GRUB dans un scénario multi-démarrage dans lequel vous ne souhaitez/n'avez pas besoin de passer par le cryptage en premier. Le chiffrement de la partition /boot offre 0,002 % de sécurité supplémentaire en protégeant contre les attaques d'Evil Maid (https://en.wikipedia.org/wiki/Evil_maid_attack), mais comporte plusieurs compromis qui peuvent ne pas justifier son utilisation lorsqu'il ne le fait pas. Cela ne s'applique pas vraiment à 99,998 % des modèles de menace des gens. Nous pouvons en débattre ici, mais j'ai l'impression que cela a été assez largement couvert en ligne (par exemple https://github.com/calamares/calamares/issues/1311), alors n'hésitez pas à faire une recherche si vous souhaitez en savoir plus. Ce guide s'adresse aux personnes conscientes des risques potentiels pour la sécurité, mais pour qui une attaque Evil Maid n'est pas quelque chose dont elles doivent s'inquiéter. Est-ce toi? Cool! Continuer à lire...

** AVIS DE NON-RESPONSABILITÉ STANDARD : veuillez lire ce guide dans son intégralité, en particulier les NOTES à la fin avant de commencer. Aucune garantie n'est offerte ou implicite et SAUVEGARDEZ TOUJOURS VOS DONNÉES**

-Téléchargez d'abord l'ISO, gravez-la sur une clé USB et démarrez avec. Les étapes et les outils disponibles pour cela sont variés. J'aime utiliser Ventoy (***voir notes à la fin) ou Gnome Disk Utility pour cela, mais cela dépend de vous.

-Sélectionnez « Installateur graphique ». Cela vous donnera une interface graphique assez simple, mais n'ayez crainte ! Pour naviguer dans le programme d'installation, utilisez votre souris ou la touche TAB pour mettre en surbrillance les boutons, etc., utilisez la barre d'espace pour sélectionner/désélectionner les options qui nécessitent "*" et utilisez Entrée (ou votre souris) pour "cliquer" sur les boutons et passer à la section suivante. .

-Sélectionnez la langue... bla bla bla. Par souci de brièveté, je ne vais pas procéder étape par étape avec les éléments évidents.

-Ignorez la création d'un mot de passe Root (laissez cette page vide) si vous souhaitez simplement vous connecter avec votre compte utilisateur et utiliser Sudo pour exécuter des commandes en tant que Root.

-Sélectionnez « Partitionnement manuel ». C'est là que ça devient délicat. Ce qui est intéressant à ce sujet, c'est qu'une fois que vous procédez de cette façon, vous n'avez plus besoin "d'utiliser l'intégralité du disque et de configurer LVM chiffré", c'est-à-dire que vous pouvez installer le chiffrement dans un scénario de démarrage multiple sans détruire tout le disque. .

-Trouvez votre disque cible dans la liste, sélectionnez l'espace libre et choisissez « créer une partition ». Nous allons créer 3 partitions, donc une fois qu'elles sont terminées, cliquez sur « configuration terminée de la partition » et sélectionnez la zone d'espace libre suivante pour créer la partition après celle que vous venez de créer. Ils devraient être les suivants :

1ère partition :

Taille : 1 024 Mio

Utiliser comme : partition EFI (aucune autre option ne sera disponible une fois cette option choisie, elle sera définie sur FAT32 et montée sur /boot/efi)

2e partition

Taille : 1 024 Mio

Utiliser comme : Ext4

Point de montage : "/boot" (fichiers statiques)

(laissez tout le reste dans son état par défaut, sauf si vous savez que vous devez changer quelque chose)

3ème partition

Taille : à vous de choisir. Vous pouvez utiliser l'espace libre restant ou choisir une valeur appropriée. Il devra contenir l'intégralité de votre installation, donc si vous ne souhaitez pas utiliser tout l'espace libre, choisissez quelque chose de sensé comme au MOINS 32 Gio.

Utiliser comme : volume physique pour le chiffrement

(fait)

Ensuite, nous allons créer la partition réelle où le /root sera placé.

-Faites défiler jusqu'à « configurer les volumes chiffrés » > écrire les modifications, puis « créer des volumes chiffrés ».

-Sélectionnez "partition" > "terminer"

-Créez votre mot de passe de cryptage

-Partitionner les disques....

-Faites défiler jusqu'à « volume crypté » et sélectionnez la partition répertoriée en dessous pour la modifier.

-Définir le point de montage sur "/" (racine) > configuration de la partition terminée

-Terminer le partitionnement et écrire les modifications sur le disque (enfin ! Mais attendez, il y a plus !!)

-L'installateur vous demandera si vous souhaitez revenir pour créer une partition d'échange. J'utilise un fichier d'échange, donc je sélectionne "non", mais c'est votre appel. Guide de création d'un fichier d'échange : https://itsfoss.com/create-swap-file-linux/

-Écrire les modifications. Cela commencera l’installation proprement dite.

Astuce bonus : si vous souhaitez un système vraiment minimaliste, lors de l'installation, désélectionnez toutes les options en plus de "Utilitaires système", puis redémarrez après l'installation. Vous n'aurez pas de bureau, juste un shell. Connectez-vous au shell avec votre nom d'utilisateur et votre mot de passe, puis faites par ex. "Sudo apt install gnome-core" (pour gnome) ou "sudo apt install kde-plasma-desktop" (pour plasma). Vous pouvez également choisir de modifier /etc/apt/sources.list pour ajouter non-free et contrib, puis d'effectuer "sudo apt update" avant cela. Vous devrez éditer /etc/network/interfaces pour supprimer (supprimer ou commenter) l'entrée de votre périphérique réseau, maintenant qu'il est géré par Gnome/KDE, sinon votre WiFi n'apparaîtra pas, même s'il sera actif. Merci à u/BollioPollio pour cette solution.

**REMARQUES: Si d'autres partitions (par exemple Ventoy ou dual boot existant) sont montées en tant que/ou EFI lors de l'installation, vous devez les sélectionner et les modifier pour "ne pas utiliser cette partition", sinon le programme d'installation les verra comme des doublons et échouera.

.....c'est ça!

Questions, commentaires, corrections bienvenues.

Un merci spécial à u/umeyume pour m'avoir expliqué tout cela avec une vidéo.

EDIT : fautes de frappe et formatage
