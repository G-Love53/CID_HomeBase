#!/usr/bin/env bash
# Commit RSS GOLD cleanup in each backend. Run from GitHub root after rss-gold-cleanup.sh --doit

set -e
GITHUB="${GITHUB_ROOT:-/Users/newmacminim4/GitHub}"

echo "=== Committing RSS GOLD cleanup ==="

cd "$GITHUB/pdf-backend"
git status -s
git add -A
git commit -m "RSS GOLD: remove test PDFs and legacy mapping" || echo "(nothing to commit in pdf-backend)"

cd "$GITHUB/plumber-pdf-backend"
git status -s
git add -A
git commit -m "RSS GOLD: remove cruft, CSS from HomeBase" || echo "(nothing to commit in plumber-pdf-backend)"

cd "$GITHUB/roofing-pdf-backend"
git status -s
git add -A
git commit -m "RSS GOLD: remove Bar scripts and test PDFs" || echo "(nothing to commit in roofing-pdf-backend)"

echo ""
echo "Done."
