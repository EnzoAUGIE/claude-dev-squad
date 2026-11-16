# 🤖 claude-dev-squad

> Une équipe d'agents IA pour **Claude Code** : un **chef de projet** qui propose l'équipe adaptée à ta demande (nombre d'agents, rôles, modèles), puis **architecte**, **développeur**, **testeur**, **relecteur** et des rôles spécialisés à la demande. Ils travaillent en séquence ou **en parallèle** (git worktrees), et peuvent s'appuyer sur les [skills de Matt Pocock](https://github.com/mattpocock/skills).

```
 /feature "ajouter une auth JWT"
        │
        ▼
 ┌─────────────┐   PLAN.md   ┌──────────────┐  commits  ┌───────────┐ TEST_REPORT.md ┌────────────┐
 │ 🏛 architecte│ ──────────▶ │ 💻 développeur│ ────────▶ │ 🧪 testeur │ ─────────────▶ │ 🔍 relecteur│
 │  (opus, RO)  │             │   (sonnet)    │ ◀──────── │  (sonnet)  │                │ (opus, RO) │
 └─────────────┘             └──────────────┘  si rouge  └───────────┘                └────────────┘
                                     ▲                                                     │
                                     └───────────── si changements bloquants ── REVIEW.md ─┘
```

### ⚡ Démarrage rapide
```bash
git clone https://github.com/EnzoAUGIE/claude-dev-squad.git ~/tools/claude-dev-squad
~/tools/claude-dev-squad/install.sh ~/code/mon-projet     # + --with-pocock si tu veux
cd ~/code/mon-projet && claude                            # accepte la confiance du dossier
> /squad ajouter un endpoint /health      # l'équipe t'est proposée, tu valides
```

### 📊 Exemple réel (démo calculatrice, Claude Pro, novembre 2026)

Demande : `/squad ajouter les fonctions puissance et racine_carree avec gestion des erreurs`

| Étape | Agent (modèle, skills) | Durée | Résultat |
|-------|------------------------|-------|----------|
| Staffing | chef-de-projet (opus) | ~1 min | taille **S** → 2 agents proposés, alternative à 1 agent ; aucun opus |
| Implémentation | developpeur (sonnet, `tdd`) | 3 min 08 | 2 fonctions en TDD, 12 tests, 2 commits |
| Tests | testeur (sonnet, `tdd`) | 1 min 51 | +20 tests de cas limites → **`STATUT: ROUGE`** : 3 échecs (`inf`/`nan` → `OverflowError` au lieu de `ValueError`) |
| Revue | relecteur (opus, `code-review`) | 3 min 05 | **`VERDICT: CHANGEMENTS`** : 🔴 bug confirmé, ligne citée, correctif proposé ; +2 🟠 non vus par les autres agents |
| Correction | developpeur → testeur → relecteur | ~8 min | **39/39 tests verts**, 100 % de couverture, 0 🔴, 0 🟠 |

Au total : **6 commits**, **1 boucle de correction**, **un bug réel détecté par le testeur et confirmé indépendamment par le relecteur**, et un risque (calcul sans limite avec de grands exposants entiers) documenté puis observé en pratique. Les livrables bruts sont dans [`examples/demo-calculatrice/exemple-sortie/`](examples/demo-calculatrice/exemple-sortie/).

---

## Sommaire
1. [Pourquoi](#1-pourquoi)
2. [Prérequis](#2-prérequis)
3. [Installation (5 minutes)](#3-installation-5-minutes)
4. [Utilisation](#4-utilisation)
5. [Les 4 agents](#5-les-4-agents)
6. [Travail en parallèle](#6-travail-en-parallèle)
7. [Intégration des skills de Matt Pocock](#7-intégration-des-skills-de-matt-pocock)
8. [Personnalisation](#8-personnalisation)
9. [Coûts et quotas](#9-coûts-et-quotas)
10. [Dépannage](#10-dépannage)
11. [Structure du dépôt](#11-structure-du-dépôt)

---

## 1. Pourquoi

Avec un seul agent, il faut tout faire dans la même conversation : le contexte se remplit, l'agent relit son propre code avec complaisance et oublie les tests. Ici, chaque rôle a :

- **son propre contexte** : chaque sous-agent part d'une fenêtre de contexte vierge ;
- **ses propres outils** : l'architecte et le relecteur **ne peuvent pas modifier le code** ;
- **son propre modèle** : `opus` pour réfléchir (architecture, revue), `sonnet` pour exécuter (code, tests) ;
- **un livrable écrit** (`PLAN.md`, `TEST_REPORT.md`, `REVIEW.md`) qui sert de contrat entre les agents.

## 2. Prérequis

| Outil | Version | Vérification |
|-------|---------|--------------|
| Claude Code | récent (testé avec 2.1.x) | `claude --version` |
| Abonnement | Claude Pro / Max, ou clé API | `claude` puis `/status` |
| git | ≥ 2.20 (worktrees) | `git --version` |
| bash | 3.2+ (macOS OK) | `bash --version` |
| jq *(optionnel)* | pour fusionner les settings | `jq --version` |
| Node.js *(optionnel)* | pour les skills Matt Pocock via `npx` | `node --version` |

```bash
# macOS
brew install jq node
npm install -g @anthropic-ai/claude-code
```

## 3. Installation (5 minutes)

### 3.1 Récupérer le kit
```bash
git clone https://github.com/EnzoAUGIE/claude-dev-squad.git ~/tools/claude-dev-squad
# ou : dézipper l'archive dans ~/tools/claude-dev-squad
cd ~/tools/claude-dev-squad
chmod +x install.sh uninstall.sh
```

### 3.2 Installer dans un projet
```bash
./install.sh ~/code/mon-projet
```

Ce que fait l'installeur. **Il n'écrase jamais rien sans `--force`.**

| Fichier installé | Rôle |
|------------------|------|
| `.claude/agents/*.md` | les 5 agents permanents |
| `.claude/commands/*.md` | les commandes `/squad`, `/feature`, `/fix-bug`, `/review`, `/parallel` |
| `.claude/scripts/*.sh` | les pipelines headless et parallèle |
| `.claude/settings.json` | permissions (autorise git/pytest, **interdit `git push`**, `rm -rf`, lecture de `.env`) ; fusionné avec le tien si jq est installé |
| `CLAUDE.md` | contexte partagé à remplir (si tu en as déjà un : `CLAUDE.dev-squad.md`) |
| `.gitignore` | ajoute `TEAM.md`, `PLAN.md`, `TEST_REPORT.md`, `REVIEW.md`, `.claude/worktrees/`, `.claude/logs/` |

Options :
```bash
./install.sh ~/code/mon-projet --with-pocock    # + skills Matt Pocock
./install.sh ~/code/mon-projet --agent-teams    # + Agent Teams (expérimental)
./install.sh --global                           # agents + commandes pour TOUS tes projets (~/.claude)
./install.sh ~/code/mon-projet --force          # réinstalle en écrasant
```

### 3.3 ⚠️ Étape indispensable : remplir `CLAUDE.md`
Ouvre `CLAUDE.md` dans ton projet et remplace chaque `<...>`, surtout la **commande de tests**. Sans elle, le testeur devra deviner.

### 3.4 Vérifier, et faire confiance au dossier (obligatoire une fois)
```bash
cd ~/code/mon-projet
claude
```
1. Au premier lancement, Claude Code demande si tu fais confiance à ce dossier : **accepte**. Sans cette étape, le mode headless (`pipeline.sh`, `parallel.sh`) **ignore les permissions** de `.claude/settings.json` et reste bloqué.
2. Demande à Claude « Quels sous-agents de ce projet peux-tu utiliser ? Donne leur nom, modèle et skills, sans rien lancer » : tu dois voir `chef-de-projet`, `architecte`, `developpeur`, `testeur` et `relecteur`.
3. Tape `/` : tu dois voir `/squad`, `/feature`, `/fix-bug`, `/review` et `/parallel`.

> ℹ️ Depuis Claude Code 2.1.3xx, l'assistant `/agents` a été retiré, et la commande shell `claude agents` liste les **sessions en arrière-plan**, pas les définitions de sous-agents. Pour vérifier, demande-le à Claude ou lance `ls .claude/agents`.

### 3.5 Essayer sur le projet de démo
```bash
cp -R ~/tools/claude-dev-squad/examples/demo-calculatrice ~/code/demo-squad
cd ~/code/demo-squad && git init -q && git add -A && git commit -qm "init"
~/tools/claude-dev-squad/install.sh .   # garde le CLAUDE.md de la démo, déjà rempli
git add -A && git commit -qm "chore: claude-dev-squad"
claude
> /feature ajouter les fonctions puissance et racine carrée avec gestion des erreurs
```

## 4. Utilisation

### 4.1 Commandes interactives (dans `claude`)

| Commande | Flux | Quand l'utiliser |
|----------|------|------------------|
| `/squad <description>` | **chef-de-projet propose l'équipe** → tu valides/modifies → exécution | par défaut, quand tu ne sais pas quelle équipe il faut |
| `/feature <description>` | architecte → dev → testeur ⟲ → relecteur ⟲ | nouvelle fonctionnalité, équipe fixe de 4 |
| `/fix-bug <description>` | testeur (test qui reproduit le bug) → dev → testeur → relecteur | correction de bug |
| `/review [branche]` | testeur → relecteur | avant de merger ton propre code |
| `/parallel <description>` | architecte découpe en lots → N développeurs en parallèle (worktrees) → tests + revue par lot | grosse demande découpable |

#### `/squad` en détail : l'équipe sur mesure
```
> /squad ajouter une authentification JWT avec page de connexion
```
1. L'agent `chef-de-projet` (opus, lecture seule) évalue la taille de la demande (S / M / L) et lit la ligne `Abonnement` de `CLAUDE.md`.
2. Il écrit `TEAM.md`, qui contient :
   - l'**équipe recommandée** : pour chaque rôle, son modèle, la raison du rôle, la raison du modèle et son étape ;
   - une **alternative économique** ;
   - les **rôles écartés**, avec la raison.
3. L'orchestrateur te montre le tableau et attend ton choix : **Valider**, **Alternative économique**, **Modifier** (ex. « passe le relecteur en sonnet », « ajoute un documentaliste ») ou **Annuler**.
4. Après validation seulement, l'équipe s'exécute : les étapes parallèles tournent dans des worktrees, et chaque rôle utilise le modèle choisi.

Exemple de proposition pour cette demande (taille M, abonnement Pro) :

| # | Rôle | Type | Modèle | Pourquoi ce modèle | Étape |
|---|------|------|--------|--------------------|-------|
| 1 | architecte | permanent | opus | choix du flux de tokens, impact sur toute l'API | 1 |
| 2 | developpeur (lot api) | permanent | sonnet | implémentation standard | 2 ∥ |
| 3 | developpeur (lot ui) | permanent | sonnet | formulaire simple | 2 ∥ |
| 4 | testeur | permanent | sonnet | tests unitaires et d'intégration | 3 |
| 5 | securite | ad hoc | opus | auth = surface d'attaque critique | 4 |
| 6 | relecteur | permanent | sonnet | Pro : opus réservé à 2 rôles | 5 |

**Rôles ad hoc** disponibles : `securite`, `documentaliste`, `frontend`, `data-engineer`, `evaluateur-ml`, `devops`, `perf`. Ils sont exécutés par un agent généraliste avec la mission décrite dans `TEAM.md`. Si l'un d'eux t'a été utile, `/squad` te propose à la fin de le transformer en agent permanent.

**Règles de recommandation des modèles** : `haiku` pour le mécanique, `sonnet` pour l'exécution, `opus` pour l'architecture, la revue, la sécurité et le debug difficile. Avec **Pro** : 2 rôles en opus maximum et 2 développeurs parallèles maximum. Tu peux modifier ces règles dans `.claude/agents/chef-de-projet.md`.

> 💡 Les commandes `/feature`, `/fix-bug`, `/review` et `/parallel` restent disponibles, avec leur équipe fixe et sans étape de validation : plus rapide quand tu sais déjà ce qu'il te faut.

Tu peux aussi appeler un agent seul, en langage naturel :
```
> utilise l'agent relecteur sur mes 3 derniers commits
> @architecte comment ajouter un cache Redis à ce service ?
```

### 4.2 Mode automatique (headless, scripts, CI)
```bash
# Pipeline séquentiel complet, sans interaction
.claude/scripts/pipeline.sh "ajouter un endpoint GET /health qui renvoie la version"

# Variables utiles
MAX_LOOPS=5 .claude/scripts/pipeline.sh "..."      # plus de boucles dev ↔ tests
SKIP_BRANCH=1 .claude/scripts/pipeline.sh "..."    # rester sur la branche courante
```
Le script refuse de démarrer si le dépôt contient des modifications non commitées. Il crée une branche `feat/...` et écrit un log dans `.claude/logs/`.

### 4.3 Après un flux
```bash
cat PLAN.md TEST_REPORT.md REVIEW.md      # lire les livrables
git log --oneline main..HEAD              # voir les commits des agents
git diff main...HEAD                      # voir tout le code
git checkout main && git merge --no-ff feat/xxx   # toi seul merges
```

## 5. Les agents permanents

| Agent | Modèle | Outils | Écrit | Ne peut PAS |
|-------|--------|--------|-------|-------------|
| 🧭 **chef-de-projet** | opus | Read, Grep, Glob, Write | `TEAM.md` | coder, lancer des agents |
| 🏛 **architecte** | opus | Read, Grep, Glob, Write, WebSearch, WebFetch | `PLAN.md` | lancer Bash, éditer le code |
| 💻 **developpeur** | sonnet | Read, Write, Edit, Bash, Grep, Glob | code + commits | push (bloqué par settings.json) |
| 🧪 **testeur** | sonnet | Read, Write, Edit, Bash, Grep, Glob | tests + `TEST_REPORT.md` | (consigne) modifier le code applicatif |
| 🔍 **relecteur** | opus | Read, Grep, Glob, Bash, Write | `REVIEW.md` | éditer le code (pas d'outil `Edit`) |

**Contrat entre agents.** Les scripts lisent des lignes fixes :
- `TEST_REPORT.md` contient `STATUT: VERT` ou `STATUT: ROUGE` ;
- `REVIEW.md` contient `VERDICT: APPROUVE` ou `VERDICT: CHANGEMENTS`.
- `TEAM.md` (lu par `/squad`) contient le tableau de l'équipe, avec les colonnes Modèle et Étape.

Le détail du fonctionnement est dans [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 6. Travail en parallèle

Trois niveaux, du plus simple au plus avancé :

**A. Plusieurs terminaux + worktrees (stable, manuel)**
```bash
claude --worktree backend      # terminal 1
claude --worktree frontend     # terminal 2
```

**B. Script `parallel.sh` (stable, automatique)**
```bash
.claude/scripts/parallel.sh \
  "api:ajouter POST /users avec validation pydantic" \
  "cli:ajouter une commande 'users list' en ligne de commande" \
  "docs:documenter l'API users dans docs/api.md"

tail -f .claude/logs/parallel-*.log      # suivre en direct
.claude/scripts/cleanup-worktrees.sh     # nettoyer après merge
```
Chaque lot obtient son worktree (`.claude/worktrees/<lot>`), sa branche (`feat/<lot>`), puis un développeur, un testeur et un relecteur dédiés. Un tableau récapitulatif s'affiche à la fin.

> ⚠️ Les lots doivent toucher des **fichiers différents**, sinon tu auras des conflits au merge. `/parallel` demande à l'architecte de garantir ce découpage.

**C. Agent Teams (expérimental)** : une session « chef d'équipe » coordonne les autres agents via une liste de tâches partagée.
```bash
./install.sh ~/code/mon-projet --agent-teams
# ou : export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
claude
> Crée une équipe : l'architecte planifie, deux développeurs (api, cli) travaillent
  dans des worktrees séparés, puis le testeur et le relecteur valident chaque branche.
```

## 7. Intégration des skills de Matt Pocock

[mattpocock/skills](https://github.com/mattpocock/skills) (licence MIT) est un ensemble de skills d'ingénierie : TDD, revue de code, spécifications, diagnostic de bugs, etc. Nos agents définissent **qui** fait le travail ; ses skills décrivent **comment** bien le faire.

> **En résumé**
> - ✅ **Automatique** : une fois liés, 4 agents appliquent leurs skills sans que tu le demandes.
> - 🙋 **À lancer toi-même** : les skills interactifs (`/grill-with-docs`, `/to-spec`) se lancent **avant** `/squad`.
> - 📁 **Par projet** : les skills s'installent et se lient **dans chaque projet**.
> - 🔌 **Optionnel** : sans skills, l'orchestrateur fonctionne normalement ; les agents suivent alors leurs seules consignes.

### 7.1 Les trois catégories de skills

**1. Préchargés dans les agents (automatique).** Un sous-agent Claude Code **n'hérite pas** des skills de ta session : il ne les utilise que s'ils sont listés dans le champ `skills:` de son fichier, qui les **précharge** au démarrage de l'agent. Le script `link-pocock-skills.sh` remplit ce champ, et seulement avec les skills réellement installés.

| Agent | Skills préchargés | Effet observé dans la démo |
|-------|-------------------|----------------------------|
| architecte | `codebase-design`, `domain-modeling` | conception des modules, vocabulaire métier |
| developpeur | `tdd`, `diagnosing-bugs` | tests écrits d'abord (rouge), puis code (vert), un commit par fonction |
| testeur | `tdd`, `diagnosing-bugs` | +20 tests de cas limites, bug localisé à la ligne près |
| relecteur | `code-review` | revue classée 🔴/🟠/🟡, chaque point avec fichier:ligne |
| chef-de-projet | — | n'en a pas besoin : il compose l'équipe |
| rôles ad hoc (`/squad`) | — | lisent un skill de `.claude/skills/` si leur mission s'y prête |

**2. Interactifs, à lancer toi-même.** Matt Pocock marque certains skills `disable-model-invocation: true` parce qu'ils te posent des questions, ce qu'un sous-agent ne peut pas faire. Claude Code refuse de les précharger ; le script les ignore avec un avertissement `⚠️`. Enchaînement recommandé pour une fonctionnalité importante :
```
> /grill-with-docs je veux un système de notifications par email   # affine la demande avec toi
> /to-spec                                                           # écrit la spec dans .scratch/<feature>/spec.md
> /squad implémente la spec de .scratch/notifications/spec.md        # l'équipe l'exécute
```
Concernés au moment de l'écriture : `grill-with-docs`, `to-spec`, `improve-codebase-architecture`.

**3. Les autres** (`triage`, `to-tickets`, `prototype`, `research`…) restent disponibles dans ta session principale, mais ne sont liés à aucun agent.

### 7.2 Installation (à faire dans chaque projet)

```bash
cd ~/code/mon-projet
~/tools/claude-dev-squad/install.sh .          # 1. l'équipe d'agents
npx skills@latest add mattpocock/skills         # 2. les skills
#   → agent cible : Claude Code · portée : Project · méthode : Copy
#   → coche au minimum : setup-matt-pocock-skills, tdd, code-review, diagnosing-bugs,
#                        codebase-design, domain-modeling, grill-with-docs, to-spec
.claude/scripts/link-pocock-skills.sh           # 3. lier les skills aux agents
claude
> /setup-matt-pocock-skills                     # 4. une fois par dépôt (issues, labels, docs)
```
Raccourci : `./install.sh <projet> --with-pocock` enchaîne les étapes 1 à 3.

Résultat attendu de l'étape 3 :
```
✔ architecte ← codebase-design domain-modeling
✔ developpeur ← tdd diagnosing-bugs
✔ testeur ← tdd diagnosing-bugs
✔ relecteur ← code-review
```

### 7.3 Vérifier

| Où | Quoi | Attendu |
|----|------|---------|
| 🖥 Terminal | `head -10 .claude/agents/developpeur.md` | un bloc `skills:` avec `- tdd` |
| 🖥 Terminal | `grep -L "disable-model-invocation: *true" .claude/skills/*/SKILL.md` | liste des skills préchargeables |
| 🤖 Claude Code | « Quels sous-agents de ce projet peux-tu utiliser ? Donne nom, modèle et skills, sans rien lancer. » | les 5 agents et leurs skills |
| 🤖 `/squad` | colonne **Skills** de `TEAM.md` | les skills de chaque agent retenu |

### 7.4 Entretien

| Situation | Commande |
|-----------|----------|
| Après une installation ou une mise à jour des skills (`npx skills update`) | `.claude/scripts/link-pocock-skills.sh`, puis relancer `claude` |
| Retirer tous les liens | `.claude/scripts/link-pocock-skills.sh --unlink` |
| Changer la correspondance agent → skills | fonction `skills_for()` dans le script |
| Un skill a été renommé en amont (ex. `to-prd` → `to-spec`) | mettre à jour `skills_for()`, puis relancer le script |

### 7.5 À savoir

- **Plugin ou `npx` ?** Le plugin géré (`/plugin install mattpocock-skills`) fonctionne pour ta session principale, mais ses skills ne sont pas dans `.claude/skills/` : le script ne peut pas les lier aux agents. Pour l'orchestrateur, utilise `npx`.
- **Coût.** Un skill préchargé ajoute son contenu au contexte de l'agent, donc des tokens. C'est pour ça que chaque agent n'en reçoit que 1 ou 2.
- **Copie `.agents/skills/`.** L'installeur `npx` en crée une copie pour d'autres outils (Cursor, Codex…). `install.sh` l'ajoute au `.gitignore`.
- **Licence.** Ce dépôt **ne redistribue pas** les skills de Matt Pocock : il explique comment les installer depuis leur source officielle. C'est plus propre pour l'auteur, et tu reçois ses mises à jour. Détails dans [docs/MATT_POCOCK.md](docs/MATT_POCOCK.md).

## 8. Personnalisation

- **Changer de modèle** : modifie `model:` dans le frontmatter d'un agent (`opus`, `sonnet`, `haiku`, ou `inherit` pour reprendre celui de la session).
- **Changer les outils** : modifie `tools:`. Retirer `Bash` du testeur l'empêche de lancer les tests, ce qui n'a pas d'intérêt. Retirer `Write` du relecteur l'empêche d'écrire `REVIEW.md` : il répondra alors dans le chat.
- **Ajouter un rôle** : copie un agent, change `name` et `description`, puis ajoute l'étape dans `commands/feature.md`. Idées : `securite`, `documentaliste`, `devops`, `perf`.
- **Autoriser plus de commandes** : complète `permissions.allow` dans `.claude/settings.json` (ex. `"Bash(docker compose:*)"`).
- **Versionner les livrables** : retire `PLAN.md` / `REVIEW.md` du `.gitignore`.

## 9. Coûts et quotas

Chaque agent consomme des tokens, et un `/feature` complet correspond à 4 à 8 sessions d'agent. En parallèle, la consommation est multipliée par le nombre de lots.

- **Claude Pro** : reste sur `/feature` (séquentiel). Utilise `/parallel` avec 2 lots maximum. Passe l'architecte et le relecteur en `sonnet` si tu atteins les limites.
- **Max / API** : `/parallel` et Agent Teams deviennent confortables.
- Suis ta consommation avec `/cost` ou `/status` dans Claude Code.

## 10. Dépannage

| Problème | Solution |
|----------|----------|
| Claude ne cite pas les agents quand tu lui demandes | Les agents sont chargés au démarrage : quitte puis relance `claude`. Vérifie que tu es à la racine du projet (là où se trouve `.claude/`). |
| Le headless affiche `Ignoring N permissions.allow entries ... not been trusted` | Lance `claude` une fois en interactif dans le dossier et accepte la demande de confiance. |
| Un agent n'est jamais appelé automatiquement | Nomme-le explicitement : « utilise l'agent testeur… ». La `description` du frontmatter pilote la délégation automatique. |
| Le pipeline headless se bloque sur une permission | Ajoute la commande dans `permissions.allow` de `.claude/settings.json`. |
| `fatal: invalid reference: main` | Ta branche s'appelle `master` : `BASE_BRANCH=master .claude/scripts/parallel.sh ...` |
| Conflits au merge après `/parallel` | Les lots touchaient les mêmes fichiers. Merge-les un par un et résous à la main, ou redécoupe. |
| `worktree already exists` | `.claude/scripts/cleanup-worktrees.sh --force` |
| Limite d'usage atteinte | Moins de lots en parallèle, `sonnet` partout, ou attends la réinitialisation du quota. |

D'autres questions sont traitées dans [docs/FAQ.md](docs/FAQ.md).

## 11. Structure du dépôt

```
claude-dev-squad/
├── README.md                 ← tu es ici
├── LICENSE                   MIT
├── CHANGELOG.md
├── install.sh                installeur (projet ou global)
├── uninstall.sh
├── template/                 ce qui est copié dans ton projet
│   ├── CLAUDE.md             contexte partagé (à remplir)
│   └── .claude/
│       ├── settings.json     permissions
│       ├── agents/           chef-de-projet, architecte, developpeur, testeur, relecteur
│       ├── commands/         /squad, /feature, /fix-bug, /review, /parallel
│       └── scripts/          pipeline.sh, parallel.sh, cleanup-worktrees.sh, link-pocock-skills.sh
├── examples/
│   └── demo-calculatrice/    mini projet Python pour tester en 2 minutes
└── docs/
    ├── ARCHITECTURE.md       fonctionnement interne
    ├── MATT_POCOCK.md        intégration des skills
    ├── FAQ.md
    └── PUBLIER_SUR_GITHUB.md checklist de publication
```

---

## Licence
MIT © 2026 Enzo Augié. Les skills de Matt Pocock restent sous leur propre licence (MIT), dans leur dépôt d'origine.

## Crédits
- [Claude Code — documentation des sous-agents](https://code.claude.com/docs/en/sub-agents)
- [mattpocock/skills](https://github.com/mattpocock/skills)
