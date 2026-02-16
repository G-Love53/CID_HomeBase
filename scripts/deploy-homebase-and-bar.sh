#!/usr/bin/env bash
# When you've changed HomeBase: push HomeBase first, then deploy Bar (with submodule update).
# Run once instead of bashing twice.
# Usage: run from CID_HomeBase root, with your HomeBase changes already staged/committed:
#   ./scripts/deploy-homebase-and-bar.sh [optional commit message]
# If you have uncommitted changes, they will be committed with the message (or a default).

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CID_HOMEBASE="$(cd "$SCRIPT_DIR/.." && pwd)"
GITHUB="${GITHUB_ROOT:-/Users/newmacminim4/GitHub}"

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
