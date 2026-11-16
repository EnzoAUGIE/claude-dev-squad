#!/usr/bin/env bash
# ------------------------------------------------------------------
# uninstall.sh — Retire les fichiers claude-dev-squad d'un projet
#
# Usage : ./uninstall.sh <CHEMIN_DU_PROJET> | --global
#
# Retire UNIQUEMENT les fichiers installés par le kit (agents, commandes,
# scripts). Ne touche ni à CLAUDE.md, ni à settings.json, ni à ton code.
# ------------------------------------------------------------------
set -euo pipefail
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
T="$KIT_DIR/template/.claude"

if [ "${1:-}" = "--global" ]; then
  BASE="$HOME/.claude"
elif [ -n "${1:-}" ] && [ -d "$1" ]; then
  BASE="$(cd "$1" && pwd)/.claude"
else
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 1
fi

for sub in agents commands scripts; do
  for f in "$T/$sub"/*; do
    tgt="$BASE/$sub/$(basename "$f")"
    [ -f "$tgt" ] && rm "$tgt" && echo "🗑  $tgt"
  done
done
echo "✅ Désinstallé de $BASE (CLAUDE.md et settings.json conservés)."
