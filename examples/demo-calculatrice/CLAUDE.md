# CLAUDE.md — Démo calculatrice

## Projet
- Nom : calculatrice
- Description : mini bibliothèque Python d'opérations arithmétiques (démo claude-dev-squad)
- Stack : Python 3.9+, pytest
- Abonnement : Pro

## Commandes
| Action | Commande |
|--------|----------|
| Installer | `pip install -r requirements.txt` |
| Tests | `python -m pytest -q` |
| Couverture | `python -m pytest --cov=calculatrice --cov-report=term-missing` |

## Structure
```
calculatrice/   code (une fonction par opération, dans operations.py)
tests/          tests pytest (test_<module>.py)
```

## Conventions
- Noms de fonctions en français, à l'infinitif (`additionner`, `diviser`)
- Type hints et docstrings obligatoires (avec section Raises si exception)
- Toute nouvelle fonction est exportée dans `calculatrice/__init__.py`
- Commits : Conventional Commits en français

## Fichiers de coordination de l'équipe d'agents
`TEAM.md` (chef-de-projet), `PLAN.md` (architecte), `TEST_REPORT.md` (testeur), `REVIEW.md` (relecteur). Ils sont ignorés par git.

## À ne jamais faire
- `git push`, merger sur main, supprimer ou affaiblir un test
