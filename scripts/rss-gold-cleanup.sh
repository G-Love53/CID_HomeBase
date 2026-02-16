#!/usr/bin/env bash
# RSS GOLD cleanup: remove cruft from Bar, Plumber, Roofer backends.
# Run from GitHub root:  bash CID_HomeBase/scripts/rss-gold-cleanup.sh
# Add --doit to actually run git rm; otherwise prints commands only.

set -e
GITHUB="${GITHUB_ROOT:-/Users/newmacminim4/GitHub}"
DOIT=
[[ "${1:-}" == "--doit" ]] && DOIT=1

run() {
  local repo="$1"
  shift
  if [[ -n "$DOIT" ]]; then
    (cd "$GITHUB/$repo" && "$@")
  else
    echo "[DRY-RUN] cd $GITHUB/$repo && $*"
  fi
}

echo "=== RSS GOLD cleanup ==="
echo "GITHUB root: $GITHUB"
[[ -z "$DOIT" ]] && echo "Dry-run. Pass --doit to execute."
echo ""

# --- Bar (pdf-backend) ---
echo "--- Bar (pdf-backend) ---"
run pdf-backend git rm -f BAR_acord125_p1_test.pdf acord_test.pdf 2>/dev/null || true
run pdf-backend git rm -rf mapping 2>/dev/null || true
echo ""

# --- Plumber ---
echo "--- Plumber ---"
run plumber-pdf-backend git rm -f "...." Universal.code-search 2>/dev/null || true
run plumber-pdf-backend git rm -f *.pdf 2>/dev/null || true
run plumber-pdf-backend git rm -rf _archive styles templates tools mapping samples 2>/dev/null || true
echo ""

# --- Roofer ---
echo "--- Roofer ---"
run roofing-pdf-backend git rm -f "bar-data-enricher (1).js" "normalizeBar125 (1).js" 2>/dev/null || true
run roofing-pdf-backend git rm -f *.pdf 2>/dev/null || true
run roofing-pdf-backend git rm -rf mapping pdf 2>/dev/null || true
echo ""

echo "Done. Run git status in each repo and commit."
echo "Plumber: src/utils/css.js was updated to use CID_HomeBase/templates/_shared/styles.css (already done in repo)."
