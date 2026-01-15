Git
===

Dans github, créer un repository, le nommer, et noter son adresse.
Sur le PC, aller dans le répertoire qui servira de dépot.

```bash
git config --global user.email "benoit.dorczynski@gmail.com"
git config --global user.name "binnotkari-wq"
git init
git add .
git commit -m "Initialisation dépot"
git remote add origin https://github.com/binnotkari-wq/the-greatest-repo.git
git branch -M main
git pull origin main
```

Cela va valider le lien avec github, et rapatrier sur le pc les fichiers déjà présents sur github.

Ensuite, on peut ajouter des fichiers dans le dossier local, puis les envoyer sur github : 

```bash
git init
git add .
git commit -m "Premier injection de fichiers dans le dépot"
git push -u origin main
```


Et les synchronisations suivantes se feront toujours avec

```bash
git init
git add .
git commit -m "descriptif du commit"
git push -u origin main
```


Si demandé :
    - Username : binnotkari-wq
    - Password : Colle ici le Token que tu viens de copier. (Note : Rien ne s'affichera quand tu colles, c'est normal pour la sécurité. Colle et appuie sur Entrée).


Token de github :
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