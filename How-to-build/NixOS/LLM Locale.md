LLM Locale
========================

Llama.cpp est très léger, et dispose d'une interface web.

On peut l'intégrer au système en me mettant dans un fichier de config .nix

```bash
  environment.systemPackages = [
    pkgs.llama-cpp-vulkan
  ];
```

Prendre la LMM llama 3.2

1. Télécharger le modèle (Fichier GGUF)

Le dépôt officiel de Meta ne fournit pas directement le format .gguf. Il faut se rendre sur Hugging Face. Je te conseille les versions de Bartowski ou MaziyarPanahi qui sont des références.

Pour tes 8 Go de RAM, télécharge la version Q4_K_M (environ 2.02 Go). C'est le meilleur rapport intelligence/poids.

curl -L https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf

curl -L https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf -o gemma-3-1b-it-Q4_K_M.gguf


Exemple si Llama a été téléchargé dans ~/LLM/Modèles : 
llama-server -m ~/LLM/Modèles/Llama-3.2-3B-Instruct-Q4_K_M.gguf -c 4096 -t 4

ou

llama-server -m ~/LLM/Modèles/gemma-3-1b-it-Q4_K_M.gguf -c 2048 -t 4


Aller sur : 
http://127.0.0.1:8080/#/


(faire un script et un raccourci dans le menu de kde pour facilier)