# Proposition d'équipe

**Demande :** Ajouter à la bibliothèque `calculatrice` les fonctions `puissance(base, exposant)` et `racine_carree(x)`, avec gestion des erreurs, tests et export dans `__init__.py`.
**Taille :** S — deux fonctions courtes sur le modèle de `diviser`, 3 fichiers (`calculatrice/operations.py`, `calculatrice/__init__.py`, `tests/test_operations.py`), aucune décision d'architecture.
**Mode :** séquentiel
**Consommation estimée :** faible

## Équipe recommandée

| # | Rôle | Type | Modèle | Skills | Pourquoi ce rôle | Pourquoi ce modèle | Étape |
|---|------|------|--------|--------|------------------|--------------------|-------|
| 1 | developpeur | permanent | sonnet | tdd, diagnosing-bugs | Implémente les 2 fonctions (type hints, docstrings avec section Raises), les exporte dans `__init__.py` et `__all__`, commit en Conventional Commits français | Implémentation simple et bien cadrée par le code existant, sonnet suffit | 1 |
| 2 | testeur | permanent | sonnet | tdd, diagnosing-bugs | Ajoute les tests nominaux et d'erreur dans `tests/test_operations.py`, lance `python -m pytest -q` et la couverture, produit `TEST_REPORT.md` | Le choix des cas limites (zéro, négatifs, flottants) demande un peu de jugement, au-delà de haiku | 2 |

Pas de `PLAN.md` puisqu'il n'y a pas d'architecte. Le developpeur suit le contrat d'erreurs ci-dessous, aligné sur `diviser` (exception native Python, message en français) :
- `racine_carree(x)` avec `x < 0` : `ValueError`.
- `puissance(0, exposant)` avec `exposant < 0` : `ZeroDivisionError`.
- `puissance(base, exposant)` avec `base < 0` et `exposant` non entier : `ValueError`, sinon Python renverrait un `complex`, ce qui violerait le type de retour `float`.

## Mission des rôles ad hoc
Aucun rôle ad hoc n'est nécessaire.

## Alternative économique
| # | Rôle | Modèle |
|---|------|--------|
| 1 | developpeur (implémentation + tests en TDD) | sonnet |

On perd le regard indépendant du testeur sur les cas limites et le `TEST_REPORT.md`. Le risque reste faible, car le skill `tdd` impose d'écrire les tests avant le code.

## Rôles écartés
- architecte : aucun choix de conception, le contrat d'erreurs tient en 3 lignes (voir plus haut) et suit le précédent de `diviser`. Un opus serait gaspillé.
- relecteur : le diff fait une trentaine de lignes et ne présente aucun risque de sécurité. Les conventions de CLAUDE.md (infinitif, type hints, Raises, export) sont vérifiées par le testeur et le developpeur. On peut l'ajouter après coup en opus si on veut une revue formelle.
- securite, documentaliste, frontend, data-engineer, evaluateur-ml, devops, perf : hors sujet (pas d'auth, pas d'API publique à documenter, pas d'interface, pas de données, pas de ML, pas de déploiement, pas d'exigence de performance).
