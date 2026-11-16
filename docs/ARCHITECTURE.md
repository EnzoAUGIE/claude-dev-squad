# Architecture de claude-dev-squad

## Concepts Claude Code utilisés

| Concept | Où | Rôle dans le kit |
|---------|----|------------------|
| **Sous-agent** | `.claude/agents/*.md` | Un rôle = un fichier Markdown avec un frontmatter (`name`, `description`, `tools`, `model`) et un prompt système. Chaque sous-agent a sa **propre fenêtre de contexte**. |
| **Commande slash** | `.claude/commands/*.md` | Un prompt réutilisable. `$ARGUMENTS` y est remplacé par ce que tu tapes après la commande. C'est l'**orchestrateur**. |
| **Settings** | `.claude/settings.json` | Permissions partagées par tous les agents (allow/deny). |
| **CLAUDE.md** | racine du projet | Mémoire de projet, lue par tous les agents. |
| **Mode headless** | `claude -p "..."` | Exécution non interactive, utilisée par les scripts. |
| **Worktree** | `claude --worktree`, `git worktree` | Un répertoire de travail isolé par agent parallèle. |
| **Agent Teams** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | Coordination native entre plusieurs sessions (expérimental). |
| **Skills** | `.claude/skills/` ou plugin | Savoir-faire chargé à la demande (ex. Matt Pocock). |

## Pourquoi des fichiers de coordination ?

Les sous-agents ne partagent pas leur contexte. Ils communiquent par des **fichiers** :

```
architecte ──écrit──▶ PLAN.md ──lu par──▶ developpeur, testeur, relecteur
testeur    ──écrit──▶ TEST_REPORT.md ──lu par──▶ developpeur (correctifs), relecteur
relecteur  ──écrit──▶ REVIEW.md ──lu par──▶ developpeur (correctifs), toi
```

Ce choix a trois avantages :
1. **Traçable** : tu peux lire chaque étape.
2. **Reprenable** : si un flux s'arrête, tu relances simplement l'agent suivant.
3. **Testable par script** : les lignes `STATUT:` et `VERDICT:` permettent les boucles automatiques.

## Séparation des privilèges

Le principe est le moindre privilège : un agent qui juge ne doit pas pouvoir « arranger » ce qu'il juge.

- L'**architecte** n'a pas `Bash` ni `Edit`. Il ne peut écrire que de nouveaux fichiers, et son prompt le limite à `PLAN.md`.
- Le **relecteur** n'a pas `Edit`. Il peut lancer `git diff`, mais son prompt lui interdit toute commande qui modifie l'état.
- Le **testeur** a le droit d'éditer, mais son prompt lui interdit le code applicatif.
- **Tous** sont bloqués par `settings.json` : pas de `git push`, pas de `rm -rf`, pas de `sudo`, pas de lecture de `.env`.

> Les interdits écrits dans les prompts sont des consignes. Ceux de `tools:` et `settings.json` sont des **contraintes techniques**. Pour une garantie forte, préfère toujours la contrainte technique.

## Flux `/squad` en détail

```
[toi] /squad X
  └─ orchestrateur
       ├─ Agent(chef-de-projet, opus) → TEAM.md   (taille, mode, équipe, modèles, alternative)
       ├─ affiche TEAM.md → [toi] Valider | Économique | Modifier ⟲ | Annuler
       ├─ pour chaque étape de TEAM.md :
       │    rôle permanent → Agent(<rôle>, modèle de TEAM.md)
       │    rôle ad hoc    → Agent(généraliste, modèle, mission de TEAM.md)
       │    étape ∥        → agents simultanés, 1 worktree par développeur
       ├─ boucles tests / revue (comme /feature)
       └─ rapport + proposition de rendre un rôle ad hoc permanent
```

La séparation entre proposition et exécution est volontaire : **rien n'est modifié dans le code avant ta validation**, et le coût en quota est annoncé avant le lancement.

## Flux `/feature` en détail

```
[toi] /feature X
  └─ orchestrateur (session principale)
       ├─ git checkout -b feat/x
       ├─ Agent(architecte)  → PLAN.md
       ├─ Agent(developpeur) → commits T1..Tn
       ├─ loop ≤3:
       │    Agent(testeur) → TEST_REPORT.md
       │    si STATUT: ROUGE → Agent(developpeur) correctifs
       ├─ loop ≤2:
       │    Agent(relecteur) → REVIEW.md
       │    si VERDICT: CHANGEMENTS + 🔴 → developpeur → testeur → relecteur
       └─ rapport final (aucun merge, aucun push)
```

## Flux `/parallel` et `parallel.sh`

```
                       ┌─ worktree api   (feat/api)  : dev → test → review
main ── architecte ────┼─ worktree cli   (feat/cli)  : dev → test → review
       (découpe lots)  └─ worktree docs  (feat/docs) : dev → test → review
                                     │
                              toi : merge un par un
```

L'isolation par worktree garantit que deux agents n'écrivent jamais dans le même répertoire. Les conflits ne peuvent apparaître qu'au **merge**, et seulement si le découpage en lots était mauvais.

## Limites connues

- Les agents peuvent se tromper : **relis toujours** `REVIEW.md` et le diff avant de merger.
- Les boucles sont plafonnées (3 et 2 passes) pour éviter de consommer ton quota sans fin.
- Agent Teams est expérimental : son comportement peut changer d'une version de Claude Code à l'autre.
