# CLAUDE.md — Contexte partagé par tous les agents

> ⚠️ **À personnaliser.** Tous les agents (architecte, développeur, testeur, relecteur) lisent ce fichier.
> Plus il est précis, meilleur est le résultat. Remplace chaque `<...>`.

## Projet
- Nom : <nom du projet>
- Description : <1-2 phrases : à quoi sert le projet>
- Stack : <ex. Python 3.12, FastAPI, SQLAlchemy, PostgreSQL>
- Abonnement : <Pro | Max | API>  ← utilisé par le chef-de-projet pour recommander les modèles

## Commandes
| Action | Commande |
|--------|----------|
| Installer | `<ex. pip install -r requirements.txt>` |
| Lancer | `<ex. uvicorn app.main:app --reload>` |
| Tests | `<ex. pytest -q>` |
| Couverture | `<ex. pytest --cov=app --cov-report=term-missing>` |
| Lint | `<ex. ruff check .>` |
| Format | `<ex. ruff format .>` |

## Structure
```
<ex.
app/          code applicatif
  api/        routes
  services/   logique métier
  models/     modèles de données
tests/        tests pytest (miroir de app/)
>
```

## Conventions
- Langue du code : anglais. Langue des commits et docs : <français/anglais>.
- Commits : Conventional Commits (`feat:`, `fix:`, `test:`, `refactor:`, `docs:`).
- <ex. typage obligatoire (type hints), docstrings Google style>
- <ex. pas de logique métier dans les routes>
- <ex. gestion d'erreurs : exceptions métier dans app/errors.py>

## Fichiers de coordination de l'équipe d'agents
| Fichier | Écrit par | Lu par |
|---------|-----------|--------|
| `TEAM.md` | chef-de-projet | orchestrateur (`/squad`), toi |
| `PLAN.md` | architecte | développeur, testeur, relecteur |
| `TEST_REPORT.md` | testeur | développeur, relecteur |
| `REVIEW.md` | relecteur | développeur, toi |

Ces fichiers sont ignorés par git (voir `.gitignore`), sauf si tu choisis de les versionner.

## À ne jamais faire
- Pousser (`git push`) ou merger sur `main`.
- Lire ou afficher `.env` ou des secrets.
- Supprimer ou affaiblir un test pour qu'il passe.
