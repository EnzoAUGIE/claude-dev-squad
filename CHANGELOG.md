# Changelog

## [1.1.1] — 2026-11-16 (retours du premier test réel)
### Corrigé
- Skills de Matt Pocock : `to-prd` → `to-spec`, `to-issues` → `to-tickets` (renommés en amont)
- Architecte : skills préchargés `codebase-design` + `domain-modeling` ; `grill-with-docs`, `to-spec` et `improve-codebase-architecture` sont non préchargeables (`disable-model-invocation`), à lancer par l'utilisateur avant `/squad`
- Vérification des agents : `/agents` a été retiré de Claude Code 2.1.3xx ; il faut demander à Claude ou lancer `ls .claude/agents`
- `.gitignore` installé : ajout de `.coverage` et `.agents/`
- Démo : ajout d'un `.gitignore` (`.venv`, `__pycache__`, `.coverage`) ; Python 3.9+
- FAQ : demandes de permission, processus bloqué, `timeout` absent sur macOS

## [1.1.0] — 2026-11-16
### Ajouté
- Agent `chef-de-projet` : propose l'équipe (taille S/M/L, nombre d'agents, rôles, modèle recommandé et justification, mode séquentiel ou parallèle) dans `TEAM.md`
- Commande `/squad` : proposition → validation ou modification par l'utilisateur → exécution de l'équipe validée
- Rôles ad hoc à la demande : securite, documentaliste, frontend, data-engineer, evaluateur-ml, devops, perf
- Ligne `Abonnement` dans `CLAUDE.md`, prise en compte pour recommander les modèles (Pro : opus limité)
- `TEAM.md` ajouté au `.gitignore` par l'installeur
- Script `link-pocock-skills.sh` : précharge les skills de Matt Pocock dans les agents (champ `skills:`), car les sous-agents n'héritent pas des skills de la session ; colonne Skills dans `TEAM.md`

## [1.0.0] — 2026-11-09
### Ajouté
- 4 sous-agents : `architecte`, `developpeur`, `testeur`, `relecteur`
- Commandes `/feature`, `/fix-bug`, `/review`, `/parallel`
- Scripts `pipeline.sh` (headless), `parallel.sh` (worktrees), `cleanup-worktrees.sh`
- `install.sh` (projet / global, `--agent-teams`, `--with-pocock`, `--force`) et `uninstall.sh`
- Permissions sécurisées (`git push`, `rm -rf`, `sudo`, `.env` interdits)
- Intégration optionnelle des skills de Matt Pocock
- Projet de démo `examples/demo-calculatrice`

## Idées pour la suite
- Workflow GitHub Actions qui lance `pipeline.sh` sur une issue étiquetée `agent`
- Agent `securite` (audit des dépendances, OWASP)
- Agent `documentaliste` (README, docstrings)
- Démo GIF dans le README
