# FAQ

**Claude Code me demande souvent « Do you want to proceed? ». Est-ce normal ?**
Oui, en mode manuel. Les commandes simples (`git`, `pytest`, `ls`) sont pré-autorisées par `.claude/settings.json`, mais les scripts Python lus via un heredoc (`python - <<EOF`), les boucles avec variables ou les globs demandent toujours confirmation. Lis la commande et accepte-la si elle reste dans le projet. Évite les options « don't ask again » trop larges (`python *`). L'option « always allow access to <dossier> » est acceptable si elle se limite à `calculatrice/` ou `tests/`.

**Un agent a lancé un calcul qui ne s'arrête pas.**
Ouvre un autre terminal et arrête le processus : `pkill -f "<texte unique de la commande>"`. Sur macOS, la commande `timeout` n'existe pas par défaut (`brew install coreutils` fournit `gtimeout`).

**`/squad` ou `/feature` ?**
`/squad` quand tu ne sais pas quelle équipe il faut, ou quand la demande est grosse ou risquée : le chef de projet propose et tu valides. `/feature` quand tu veux simplement lancer l'équipe standard de 4, sans étape de validation.

**Le chef de projet propose trop d'agents (ou des modèles trop chers).**
Choisis « Alternative économique », ou réponds « Modifier : retire X, passe Y en sonnet ». Pour changer ses règles de façon durable, édite les tableaux de `.claude/agents/chef-de-projet.md` et la ligne `Abonnement` de `CLAUDE.md`.

**Comment un rôle ad hoc (ex. securite) est-il exécuté sans fichier d'agent ?**
L'orchestrateur lance un agent généraliste avec le modèle choisi et la mission écrite dans `TEAM.md`. Un nouveau fichier dans `.claude/agents/` n'est chargé qu'au redémarrage de `claude` : c'est pour ça que les rôles ad hoc passent par cet agent généraliste.

**Est-ce que ça marche avec Claude Pro ?**
Oui. Le flux séquentiel `/feature` est adapté à Pro. Le mode parallèle consomme N fois plus : limite-toi à 2 lots.

**Est-ce que ça marche pour d'autres langages que Python ?**
Oui. Les agents sont agnostiques : ils utilisent les commandes que tu indiques dans `CLAUDE.md`. Pour du JS/TS, mets `npm test` ; pour Java, `mvn test`. Ajoute la commande correspondante dans `permissions.allow` de `settings.json`.

**Les agents peuvent-ils casser mon dépôt ?**
Ils travaillent sur une branche dédiée, ne peuvent pas `push` et ne peuvent pas `rm -rf`. Au pire, tu supprimes la branche : `git checkout main && git branch -D feat/xxx`.

**Pourquoi l'architecte et le relecteur sont-ils en `opus` ?**
Ce sont les rôles où la qualité du raisonnement compte le plus, et ils écrivent peu. Le développeur et le testeur produisent beaucoup de tokens : `sonnet` y offre un meilleur rapport qualité/coût.

**Je veux que l'architecte me pose des questions avant de planifier.**
Dans `/feature`, c'est déjà le cas si ses hypothèses changent le périmètre. Pour un questionnement systématique, lance toi-même `/grill-with-docs` (skill de Matt Pocock) avant `/squad`, ou lance d'abord `@architecte pose-moi tes questions sur : ...`.

**Quelle différence entre `/parallel` et `parallel.sh` ?**
`/parallel` est interactif : l'architecte découpe les lots et tu valides. `parallel.sh` est un script : tu fournis toi-même les lots, et il tourne sans interaction (ex. en CI ou pendant que tu fais autre chose).

**Agent Teams ou sous-agents ?**
Les sous-agents sont stables et rapportent à une session principale. Agent Teams (expérimental) lance des sessions complètes qui se coordonnent entre elles. Commence par les sous-agents.

**Peut-on l'utiliser dans GitHub Actions ?**
Oui, via `pipeline.sh` (mode `claude -p`) avec une clé API dans les secrets du dépôt. C'est une évolution possible du projet (voir CHANGELOG).

**Comment désinstaller ?**
`./uninstall.sh ~/code/mon-projet`. Le script retire les agents, commandes et scripts, sans toucher à `CLAUDE.md` ni à `settings.json`.
