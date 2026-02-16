#!/usr/bin/env bash
# Deploy Bar backend (pdf-backend): pull latest CID_HomeBase submodule, commit if changed, push. Render deploys from git.
# Run this after you've pushed changes to CID_HomeBase (e.g. new SUPP_BAR mapping).
# Usage:  bash scripts/deploy-bar-backend.sh   (from CID_HomeBase or anywhere)

set -e
GITHUB="${GITHUB_ROOT:-/Users/newmacminim4/GitHub}"
cd "$GITHUB/pdf-backend"

cd CID_HomeBase && git pull origin main && cd ..
git add CID_HomeBase
git diff --staged --quiet CID_HomeBase || git commit -m "chore: update CID_HomeBase submodule"
git push origin main
echo "Done. Render will deploy from the push."
