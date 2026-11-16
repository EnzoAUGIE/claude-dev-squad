# Rapport de tests

STATUT: VERT

| Suite | Passés | Échoués | Ignorés |
|-------|--------|---------|---------|
| tests/test_operations.py | 39 | 0 | 0 |

## Échecs
Aucun. Les 3 tests précédemment en échec (`..._exposant_infini_ou_nan_leve_valueerror_du_contrat[inf]`, `[-inf]`, `[nan]`) passent après le commit c06eeff.

## Tests ajoutés
- base négative avec exposant flottant entier (`-2 ** 3.0`, `-2 ** -2.0`)
- base `-inf` avec exposant entier
- `puissance(nan, 0) == 1.0`
- `puissance(0, nan)` renvoie nan sans lever

## Observations
- Le grand exposant entier (`10**9`) reste un risque documenté, non limité par le code. Il n'est pas testé à pleine échelle.
- L'environnement local utilise Python 3.9.13, alors que CLAUDE.md vise 3.10+. Pas d'effet sur les résultats.

## Couverture
100 % (calculatrice/__init__.py et calculatrice/operations.py, aucune ligne manquante).
