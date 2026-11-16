# Publier claude-dev-squad sur GitHub

## 1. Créer le dépôt (commandes à copier-coller)

```bash
cd ~/tools/claude-dev-squad          # dossier dézippé
git init
git add -A
git commit -m "feat: équipe de 4 agents Claude Code (architecte, dev, testeur, relecteur)"
git branch -M main

# Avec GitHub CLI (brew install gh && gh auth login)
gh repo create EnzoAUGIE/claude-dev-squad --public --source=. --push \
  --description "Équipe de 4 agents IA pour Claude Code : architecte, développeur, testeur, relecteur — séquentiel ou parallèle (git worktrees)"

# Sans gh : crée le dépôt vide sur github.com, puis
# git remote add origin git@github.com:EnzoAUGIE/claude-dev-squad.git
# git push -u origin main
```

## 2. Ajouter les topics (meilleure visibilité)
```bash
gh repo edit EnzoAUGIE/claude-dev-squad \
  --add-topic claude-code --add-topic ai-agents --add-topic multi-agent \
  --add-topic subagents --add-topic llm --add-topic developer-tools \
  --add-topic git-worktree --add-topic anthropic
```

## 3. Ce qui fait la différence pour un recruteur

- [ ] **Une démo visuelle** : enregistre un GIF ou une vidéo de 30 s de `/feature` sur `examples/demo-calculatrice` (outil `vhs`, `asciinema` ou `terminalizer`) et place-la en haut du README.
- [ ] **Un exemple réel de résultat** : commite dans `examples/demo-calculatrice/exemple-sortie/` un vrai `PLAN.md`, `TEST_REPORT.md` et `REVIEW.md` produits par les agents.
- [ ] **Une section « Résultats »** dans le README, avec des chiffres mesurés et honnêtes (ex. « sur la démo : 6 tâches, 14 tests générés, 2 boucles de correction, ~8 min »).
- [ ] **Épingler le dépôt** sur ton profil GitHub (Customize your pins).
- [ ] **Une release** : `gh release create v1.0.0 --generate-notes`.
- [ ] **Le mentionner sur ton CV et ton portfolio** : « Conception d'un système multi-agents IA (Claude Code) avec séparation des rôles, orchestration séquentielle et parallèle (git worktrees), pipeline headless. »

## 4. À vérifier avant de rendre public
- [ ] Aucun secret, token ou chemin personnel dans les fichiers (`grep -rn "token\|password\|/Users/" .`).
- [ ] Le README s'affiche bien sur GitHub (schémas, tableaux, liens relatifs).
- [ ] `./install.sh examples/demo-calculatrice` fonctionne sur une machine propre.
- [ ] La licence MIT porte ton nom.
