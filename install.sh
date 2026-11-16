#!/usr/bin/env bash
# ------------------------------------------------------------------
# install.sh — Installe l'équipe d'agents claude-dev-squad
#
# Usage :
#   ./install.sh [CHEMIN_DU_PROJET] [options]
#
# Options :
#   --global        installe agents + commandes dans ~/.claude/ (tous tes projets)
#   --agent-teams   active la fonctionnalité expérimentale Agent Teams
#   --with-pocock   lance l'installation des skills de Matt Pocock (npx)
#   --force         écrase les fichiers existants (sinon : jamais d'écrasement)
#   -h, --help      affiche cette aide
#
# Exemples :
#   ./install.sh ~/code/mon-projet
#   ./install.sh ~/code/mon-projet --with-pocock
#   ./install.sh --global
#
# Compatible bash 3.2 (macOS) et Linux. Ne supprime jamais rien.
# ------------------------------------------------------------------
set -euo pipefail

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$KIT_DIR/template"
TARGET=""
GLOBAL=0
AGENT_TEAMS=0
POCOCK=0
FORCE=0

c_ok()   { printf "\033[32m✔\033[0m %s\n" "$1"; }
c_warn() { printf "\033[33m⚠\033[0m %s\n" "$1"; }
c_err()  { printf "\033[31m✖\033[0m %s\n" "$1" >&2; }
c_info() { printf "\033[36mℹ\033[0m %s\n" "$1"; }

usage() { sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --global)      GLOBAL=1 ;;
    --agent-teams) AGENT_TEAMS=1 ;;
    --with-pocock) POCOCK=1 ;;
    --force)       FORCE=1 ;;
    -h|--help)     usage; exit 0 ;;
    -*)            c_err "Option inconnue : $1"; usage; exit 1 ;;
    *)             TARGET="$1" ;;
  esac
  shift
done

# copie un fichier sans écraser (sauf --force)
safe_copy() {
  src="$1"; dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
    c_warn "existe déjà, conservé : $dst"
  else
    cp "$src" "$dst"
    c_ok "$dst"
  fi
}

copy_dir() {
  src_dir="$1"; dst_dir="$2"
  for f in "$src_dir"/*; do
    [ -f "$f" ] || continue
    safe_copy "$f" "$dst_dir/$(basename "$f")"
  done
}

# active Agent Teams dans un settings.json (via jq si dispo)
enable_agent_teams() {
  settings="$1"
  if command -v jq >/dev/null 2>&1; then
    [ -f "$settings" ] || echo '{}' > "$settings"
    tmp="$(mktemp)"
    jq '.env = ((.env // {}) + {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"})' "$settings" > "$tmp" && mv "$tmp" "$settings" && chmod 644 "$settings"
    c_ok "Agent Teams activé dans $settings"
  else
    c_warn "jq non installé : ajoute à la main dans $settings :"
    echo '    "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" }'
    echo "    (ou : brew install jq / sudo apt install jq, puis relance avec --agent-teams)"
  fi
}

echo ""
echo "🤖 claude-dev-squad — installation"
echo "-----------------------------------"

# --- Prérequis -----------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  c_ok "Claude Code détecté : $(claude --version 2>/dev/null | head -1)"
else
  c_warn "Claude Code introuvable. Installe-le : npm install -g @anthropic-ai/claude-code"
fi
command -v git >/dev/null 2>&1 || { c_err "git est requis."; exit 1; }

# --- Installation globale ---------------------------------------------
if [ "$GLOBAL" -eq 1 ]; then
  echo ""
  c_info "Installation GLOBALE dans ~/.claude/"
  copy_dir "$TEMPLATE/.claude/agents"   "$HOME/.claude/agents"
  copy_dir "$TEMPLATE/.claude/commands" "$HOME/.claude/commands"
  [ "$AGENT_TEAMS" -eq 1 ] && enable_agent_teams "$HOME/.claude/settings.json"
  c_info "Les scripts (pipeline.sh, parallel.sh) s'installent par projet : ./install.sh <projet>"
fi

# --- Installation projet ----------------------------------------------
if [ "$GLOBAL" -eq 0 ] || [ -n "$TARGET" ]; then
  TARGET="${TARGET:-$PWD}"
  [ -d "$TARGET" ] || { c_err "Dossier introuvable : $TARGET"; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  if [ "$TARGET" = "$KIT_DIR" ]; then
    c_err "Tu es dans le dossier du kit. Indique le chemin de TON projet : ./install.sh ~/code/mon-projet"
    exit 1
  fi
  echo ""
  c_info "Installation dans le projet : $TARGET"

  if ! git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    c_warn "Ce dossier n'est pas un dépôt git. Les agents en ont besoin (commits, diff, worktrees)."
    c_info  "Fais : cd \"$TARGET\" && git init && git add -A && git commit -m 'init'"
  fi

  copy_dir "$TEMPLATE/.claude/agents"   "$TARGET/.claude/agents"
  copy_dir "$TEMPLATE/.claude/commands" "$TARGET/.claude/commands"
  copy_dir "$TEMPLATE/.claude/scripts"  "$TARGET/.claude/scripts"
  chmod +x "$TARGET"/.claude/scripts/*.sh

  # settings.json : fusion si jq, sinon copie à côté
  if [ -f "$TARGET/.claude/settings.json" ] && [ "$FORCE" -ne 1 ]; then
    if command -v jq >/dev/null 2>&1; then
      tmp="$(mktemp)"
      jq -s '
        .[0] as $a | .[1] as $b |
        $a * $b
        | .permissions.allow = ((($a.permissions.allow // []) + ($b.permissions.allow // [])) | unique)
        | .permissions.deny  = ((($a.permissions.deny  // []) + ($b.permissions.deny  // [])) | unique)
      ' "$TARGET/.claude/settings.json" "$TEMPLATE/.claude/settings.json" > "$tmp" \
        && mv "$tmp" "$TARGET/.claude/settings.json" && chmod 644 "$TARGET/.claude/settings.json"
      c_ok "permissions fusionnées dans .claude/settings.json"
    else
      cp "$TEMPLATE/.claude/settings.json" "$TARGET/.claude/settings.dev-squad.json"
      c_warn "settings.json existant conservé. Fusionne à la main : .claude/settings.dev-squad.json"
    fi
  else
    safe_copy "$TEMPLATE/.claude/settings.json" "$TARGET/.claude/settings.json"
  fi

  # CLAUDE.md : jamais écrasé
  if [ -f "$TARGET/CLAUDE.md" ] && [ "$FORCE" -ne 1 ]; then
    cp "$TEMPLATE/CLAUDE.md" "$TARGET/CLAUDE.dev-squad.md"
    c_warn "CLAUDE.md existant conservé. Modèle copié dans CLAUDE.dev-squad.md : ajoute ses sections au tien."
  else
    safe_copy "$TEMPLATE/CLAUDE.md" "$TARGET/CLAUDE.md"
  fi

  # .gitignore
  GI="$TARGET/.gitignore"
  touch "$GI"
  for line in "TEAM.md" "PLAN.md" "TEST_REPORT.md" "REVIEW.md" ".claude/worktrees/" ".claude/logs/" ".claude/settings.local.json" ".coverage" ".agents/"; do
    grep -qxF "$line" "$GI" || { echo "$line" >> "$GI"; c_ok ".gitignore += $line"; }
  done

  [ "$AGENT_TEAMS" -eq 1 ] && enable_agent_teams "$TARGET/.claude/settings.json"
fi

# --- Skills Matt Pocock -------------------------------------------------
if [ "$POCOCK" -eq 1 ]; then
  echo ""
  c_info "Skills de Matt Pocock (https://github.com/mattpocock/skills, licence MIT)"
  if command -v npx >/dev/null 2>&1; then
    c_info "Lancement de l'installeur interactif. Sélectionne AU MINIMUM : setup-matt-pocock-skills, tdd, code-review, diagnosing-bugs, codebase-design, domain-modeling (+ grill-with-docs, to-spec à lancer toi-même). Agent cible : Claude Code ; portée : Project ; méthode : Copy."
    ( [ -n "${TARGET:-}" ] && cd "$TARGET"; npx skills@latest add mattpocock/skills ) \
      || c_warn "L'installeur a échoué. Alternative dans Claude Code : /plugin install mattpocock-skills"
    if [ -n "${TARGET:-}" ] && [ -x "$TARGET/.claude/scripts/link-pocock-skills.sh" ]; then
      ( cd "$TARGET" && .claude/scripts/link-pocock-skills.sh ) || true
    fi
    c_info "Ensuite, dans Claude Code (une fois par repo) : /setup-matt-pocock-skills"
    c_info "Si tu installes ou mets à jour des skills plus tard : .claude/scripts/link-pocock-skills.sh"
  else
    c_warn "npx introuvable (installe Node.js). Alternative dans Claude Code : /plugin install mattpocock-skills"
  fi
fi

# --- Fin --------------------------------------------------------------
echo ""
echo "-----------------------------------"
c_ok "Installation terminée."
echo ""
echo "Étapes suivantes :"
echo "  1. Personnalise CLAUDE.md (stack, commande de tests, conventions)"
echo "  2. cd \"${TARGET:-ton-projet}\" && claude   → ACCEPTE la demande de confiance du dossier"
echo "  3. Vérifie les agents :   demande « quels sous-agents de ce projet peux-tu utiliser ? »"
echo "  4. Lance un flux :        /squad ajouter un endpoint /health   (équipe proposée, tu valides)"
echo "                       ou   /feature ajouter un endpoint /health  (équipe fixe de 4)"
echo ""
echo "Doc complète : $KIT_DIR/README.md"
