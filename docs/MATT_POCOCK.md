# Intégrer les skills de Matt Pocock

[mattpocock/skills](https://github.com/mattpocock/skills) est un dépôt public, sous licence MIT, qui contient des « skills » d'ingénierie : des fichiers `SKILL.md` que Claude Code charge à la demande. Matt Pocock est formateur TypeScript ; ses skills encodent des pratiques comme le TDD, la revue de code, la rédaction de PRD ou le découpage en issues.

## Agents et skills : quelle différence ?

| | Sous-agent (ce kit) | Skill (Matt Pocock) |
|-|--------------------|--------------------|
| Nature | **Qui** fait le travail | **Comment** bien faire un type de travail |
| Contexte | Fenêtre de contexte séparée | Chargé dans le contexte de l'agent qui l'utilise |
| Exemple | « le testeur » | « la méthode TDD » |

Les deux sont donc **complémentaires** : nos agents sont les rôles, ses skills sont leurs méthodes de travail.

## Installation

### Option 1 : copies éditables (recommandé, et nécessaire pour l'orchestrateur)
```bash
cd ~/code/mon-projet
npx skills@latest add mattpocock/skills
```
L'installeur est interactif. Coche au minimum :
- `setup-matt-pocock-skills` (**obligatoire** : il configure le dépôt pour les autres skills)
- `tdd`
- `code-review`
- `diagnosing-bugs`
- `codebase-design`, `domain-modeling` (préchargés dans l'architecte)
- `grill-with-docs`, `to-spec` (à lancer toi-même avant `/squad`)
- *(optionnel)* `to-tickets`, `improve-codebase-architecture`, `triage`

Réponses à l'installeur : **agent cible** = Claude Code (une copie va aussi dans `.agents/skills/` pour les autres outils, que l'installeur de ce kit ajoute au `.gitignore`), **portée** = Project, **méthode** = Copy.

Mise à jour : `npx skills update`

### Option 2 : plugin Claude Code (géré : pour ta session uniquement, non liable aux agents)
```
claude
> /plugin install mattpocock-skills
```
Les mises à jour sont automatiques, mais tu ne peux pas modifier les fichiers.

### Dans les deux cas, une fois par dépôt
```
> /setup-matt-pocock-skills
```
Il te demande :
1. ton gestionnaire d'issues (GitHub, Linear ou fichiers locaux) ;
2. tes labels de triage ;
3. où ranger la documentation produite.

Il ajoute ensuite une section dans `CLAUDE.md` / `AGENTS.md` et crée `docs/agents/`.

## Comment nos agents les utilisent

Les sous-agents **n'héritent pas** des skills de la session principale. Le champ `skills:` du frontmatter d'un agent précharge le contenu complet des skills listés au démarrage de cet agent. Le script `.claude/scripts/link-pocock-skills.sh` :
1. cherche les skills dans `.claude/skills/` (projet) et `~/.claude/skills/` ;
2. ajoute à chaque agent ceux qui le concernent ;
3. ignore les skills absents ou marqués `disable-model-invocation: true`, qui ne peuvent pas être préchargés.

Exemple de résultat dans `.claude/agents/developpeur.md` :
```yaml
---
name: developpeur
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
skills:
  - tdd
  - diagnosing-bugs
---
```
Une fois liés, les agents appliquent ces skills **d'eux-mêmes**. Relance le script après chaque installation ou mise à jour des skills, puis relance `claude`.

| Agent | Skill | Effet |
|-------|-------|-------|
| architecte | `codebase-design` | Conception des modules et interfaces |
| architecte | `domain-modeling` | Vocabulaire métier, `CONTEXT.md`, ADR |
| developpeur | `tdd` | Boucle test d'abord |
| developpeur, testeur | `diagnosing-bugs` | Diagnostic méthodique d'un échec |
| relecteur | `code-review` | Grille de revue supplémentaire |

> Les noms de skills peuvent évoluer d'une version à l'autre du dépôt de Matt Pocock. Si un nom change, mets à jour la section correspondante dans `.claude/agents/*.md`. Pour connaître les skills disponibles, demande dans Claude Code : « quels skills sont disponibles ? » ou utilise `/ask-matt`.

## Flux combiné recommandé pour une grosse fonctionnalité

```
> /grill-with-docs je veux un système de notifications par email
  (affiner la demande avec toi : skill interactif, non préchargeable)
> /to-spec
  (écrire la spec dans .scratch/<feature>/spec.md)
> /feature <demande affinée>
  (l'architecte lit la spec et applique codebase-design, le développeur applique tdd, le relecteur applique code-review)
```

## Skills non préchargeables

Matt Pocock marque certains skills `disable-model-invocation: true` : ils ne s'exécutent que si **tu** les appelles, souvent parce qu'ils te posent des questions. Claude Code refuse de les précharger dans un sous-agent. C'est le cas, au moment de l'écriture, de `grill-with-docs`, `to-spec` et `improve-codebase-architecture`. Le script les ignore avec un avertissement `⚠️`.

## Licence et publication

Ce dépôt **ne copie pas** les fichiers de Matt Pocock : il donne la commande pour les installer depuis leur source officielle. Si tu choisis d'en inclure une copie dans ton dépôt (option `npx` dans `.claude/skills/`), la licence MIT l'autorise à condition de **conserver sa notice de licence et de copyright**. Le plus simple et le plus correct reste de ne pas les commiter :

```bash
echo ".claude/skills/" >> .gitignore   # si tu ne veux pas versionner les skills installés
```
