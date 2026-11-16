# Revue de code

VERDICT: OK

Périmètre : `git diff main...HEAD` sur `feat/puissance-racine-carree`, soit 6 commits (c69aecf, f32caeb, 1ea7126, 34a2419, c06eeff, dac11b8). C'est une deuxième passe, faite après la boucle de correction.
Spec de référence : le contrat d'erreurs de `TEAM.md`. Il n'y a ni `PLAN.md` ni spec sous `docs/` ou `.scratch/`.
`TEST_REPORT.md` : STATUT VERT, 39 passés et 0 échoué. J'ai relancé `python -m pytest -q` : `39 passed`.

## Suivi de la revue précédente

| Point | Statut | Constat |
|-------|--------|---------|
| 🔴 `int()` sur inf/nan dans `puissance` | Résolu | `calculatrice/operations.py:48` utilise maintenant `isinstance(exposant, int) or float(exposant).is_integer()`. `puissance(-2, inf)`, `(-2, -inf)` et `(-2, nan)` lèvent le `ValueError` du contrat, ce que vérifie `tests/test_operations.py:88-92`. La branche `isinstance` évite bien l'`OverflowError` de `float()` sur un entier supérieur à 1e308. J'ai vérifié que `puissance(0, -10**400)` lève `ZeroDivisionError` et que `Fraction(1, 3)` et `Decimal('0.5')` lèvent `ValueError`. |
| 🔴 `TEST_REPORT.md` ROUGE | Résolu | Le rapport est VERT avec 39 tests et 100 % de couverture. Aucun test n'a été affaibli ni supprimé : le diff des tests ne fait qu'en ajouter. |
| 🟠 `OverflowError` absent de Raises | Résolu | La docstring le mentionne en `calculatrice/operations.py:41-42`, avec un exemple. |
| 🟠 Risque DoS des grands exposants entiers | Résolu par documentation, comme choix assumé | L'avertissement figure en `calculatrice/operations.py:33-35`. Aucune limite n'a été ajoutée, et c'est voulu : c'était l'une des trois options proposées. C'est acceptable pour une bibliothèque de démo sans entrée utilisateur. Le risque est réel : en sondant le code pendant cette revue, `puissance(-2, 10**400)` a tourné plus de 120 s sans rendre la main avant que je l'arrête. |

## 🔴 Bloquant

Aucun.

## 🟠 Important

Aucun.

## 🟡 Mineur

- `tests/test_operations.py:126` : le commentaire « Comportement actuel (non documenté dans Raises) : OverflowError natif » est devenu faux depuis c06eeff.
  → Le remplacer par « Contrat documenté dans Raises : OverflowError natif. »
- `calculatrice/operations.py:30` : le type annoncé est `-> float`, mais deux `int` donnent un `int` (`puissance(2, 10)` renvoie 1024, `puissance(-2, True)` renvoie un `int`). Ce point n'a pas changé depuis la première revue. Il est cohérent avec les autres opérations et reste à trancher, pas à corriger.
  → Au minimum, l'écrire dans la docstring.
- `calculatrice/operations.py:53` : l'`OverflowError` natif porte un message en anglais, par exemple `(34, 'Result too large')` pour `puissance(-2, 1e300)`. Les autres erreurs du module ont un message en français. C'est documenté, donc acceptable.
  → Option : capturer l'erreur et la relever avec un message français. Si on le fait, il faut rendre le test de la ligne 125 plus strict avec `match=`.
- `tests/test_operations.py:85` : `MSG_NEG` est défini au milieu du fichier, alors que les messages sont déjà copiés en dur plus haut (lignes 54, 59, 77) et plus bas (ligne 146). C'est un possible Duplicated Code.
  → Placer les constantes de messages en tête de fichier et les réutiliser partout.
- `tests/test_operations.py:81` : la section « Tests complémentaires (QA) » découpe le fichier selon l'auteur des tests, pas selon la fonction testée. Les commits dac11b8 ajoutent encore des tests de `puissance` après `test_exports_publics` (lignes 172-187).
  → Regrouper les tests par fonction, ou créer les classes `TestPuissance` et `TestRacineCarree`.
- `tests/test_operations.py:95-101` : un seul test contient trois `pytest.raises`, donc le premier échec masque les suivants.
  → Le paramétrer avec `@pytest.mark.parametrize("base, exposant", [...])`.
- `tests/test_operations.py:110`, `:156` et `:187` : NaN est vérifié par `x != x`.
  → Utiliser `math.isnan(...)`, plus lisible.
- `calculatrice/operations.py:64` : `math.sqrt(x)` serait plus explicite que `x**0.5`. Il faut vérifier que `-0.0` et `nan` gardent leur comportement actuel (lignes 150 et 155).
- `calculatrice/__init__.py:11` : la ligne fait 91 caractères et ne suit pas le format multi-ligne de l'import juste au-dessus. Aucun linter n'est configuré.
- Environnement : `TEST_REPORT.md` signale Python 3.9.13 en local, alors que CLAUDE.md vise 3.10+. Le code n'utilise rien de spécifique à 3.10, donc ce n'est pas bloquant.

## Standards

Sources : CLAUDE.md et la base de smells.

- Noms : `puissance` et `racine_carree` sont des substantifs, alors que CLAUDE.md demande l'infinitif. C'est un écart de forme imposé par la demande de `TEAM.md`, et il n'est pas bloquant.
- Type hints et docstrings avec Raises : conformes. Raises couvre maintenant `ZeroDivisionError`, `ValueError` et `OverflowError`.
- Export dans `__init__.py` et `__all__` : conforme, et vérifié par `tests/test_operations.py:164-169`.
- Commits : les 6 suivent Conventional Commits en français. Le message de c06eeff explique bien le pourquoi.
- Smells (jugement) : possible Duplicated Code sur les messages d'erreur dans les tests (voir 🟡). Rien dans le code applicatif.

## Spec

Source : le contrat de `TEAM.md`.

- « `racine_carree(x)` avec `x < 0` : `ValueError` » : implémenté et testé, y compris pour `-inf` et `-1e-300`.
- « `puissance(0, exposant)` avec `exposant < 0` : `ZeroDivisionError` » : implémenté et testé, y compris pour `-0.0`, `-inf` et `-0.5`.
- « `puissance(base, exposant)` avec `base < 0` et `exposant` non entier : `ValueError` » : implémenté, et cette fois complet. Les exposants finis, `inf`, `-inf` et `nan` sont couverts, et les flottants entiers (`3.0`, `-2.0`) passent bien.
- Hors périmètre : `.gitignore:12` ajoute `.coverage`. C'est anodin.

## Points positifs

- La correction est minimale et ciblée : une ligne de logique et la docstring. Elle reprend la suggestion de la revue sans élargir le périmètre.
- Le contrat a été corrigé côté code. Les tests en échec sont restés intacts.
- Les nouveaux tests (dac11b8) ciblent exactement les risques de régression du correctif : flottants entiers négatifs, base `-inf`, `nan` en base comme en exposant.
- La couverture est de 100 % et les messages sont vérifiés avec `match=`.
- Les commits sont atomiques et leurs messages sont clairs.
