# Démo : calculatrice

Mini projet Python pour tester **claude-dev-squad** en 2 minutes.

```bash
cp -R examples/demo-calculatrice ~/code/demo-squad
cd ~/code/demo-squad
python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt
pytest -q                                    # 5 tests verts
git init -q && git add -A && git commit -qm "init"
~/tools/claude-dev-squad/install.sh .         # le CLAUDE.md de la démo, déjà rempli, est conservé
rm -f CLAUDE.dev-squad.md                     # modèle vide inutile ici
git add -A && git commit -qm "chore: claude-dev-squad"
claude
```

Puis, dans Claude Code, essaie :
```
/feature ajouter les fonctions puissance et racine_carree avec gestion des erreurs (racine d'un négatif)
/fix-bug diviser(0.1+0.2, 0.3) ne renvoie pas exactement 1.0, ajouter une option d'arrondi
/review
```

Ou en mode automatique :
```bash
.claude/scripts/pipeline.sh "ajouter une fonction moyenne(liste) qui lève ValueError si la liste est vide"
```
