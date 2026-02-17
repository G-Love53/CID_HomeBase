#!/usr/bin/env bash
# When you've changed HomeBase: sync from local submodule, push HomeBase, then deploy Bar.
# Run from CID_HomeBase root. Your clean local files live in pdf-backend/CID_HomeBase (submodule);
# this script copies them here so Git pushes the right content.
# Usage:  ./scripts/deploy-homebase-and-bar.sh [optional commit message]

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CID_HOMEBASE="$(cd "$SCRIPT_DIR/.." && pwd)"
GITHUB="${GITHUB_ROOT:-/Users/newmacminim4/GitHub}"
SUBMODULE="$GITHUB/pdf-backend/CID_HomeBase"

# Step 0: Sync FROM pdf-backend/CID_HomeBase (local clean) INTO this repo so Git has latest
if [[ -d "$SUBMODULE" ]]; then
  echo "Syncing local submodule -> standalone (so Git pushes your clean files)..."
  rsync -a --delete \
    --exclude='.git' \
    --exclude='.DS_Store' \
    --exclude='node_modules' \
    "$SUBMODULE/" "$CID_HOMEBASE/"
  echo "Sync done."
else
  echo "Note: $SUBMODULE not found; skipping sync (using current dir only)."
fi
echo ""

cd "$CID_HOMEBASE"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Step 1: Push HomeBase (commit if there are changes)
if ! git diff --quiet || ! git diff --cached --quiet; then
  MSG="${1:-Update HomeBase (templates/mapping)}"
  git add -A
  git commit -m "$MSG"
fi
echo "Pushing CID_HomeBase ($BRANCH)..."
git push origin "$BRANCH"
echo ""

# Step 2: Deploy Bar with submodule update
exec "$SCRIPT_DIR/deploy-bar-backend.sh" --submodule
