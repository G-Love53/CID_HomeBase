#!/usr/bin/env bash
# Convert one PDF page to SVG with Inkscape (--export-text-to-path so checkboxes = paths, not fonts).
# Output: standalone CID_HomeBase when CID_HOMEBASE_STANDALONE set; else submodule templates/.
# Usage: bash scripts/pdf-page-to-svg.sh <input.pdf> [page=1]
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
[[ -n "${CID_HOMEBASE_STANDALONE:-}" && -d "$CID_HOMEBASE_STANDALONE" ]] && REPO_ROOT="$CID_HOMEBASE_STANDALONE"

INPUT_PDF="$1"
PAGE="${2:-1}"
[[ -z "$INPUT_PDF" || ! -f "$INPUT_PDF" ]] && { echo "Usage: $0 <input.pdf> [page]"; exit 1; }

PAGE_NAME="$(basename "$INPUT_PDF" .pdf)"
if [[ "$PAGE_NAME" =~ ^(.+)[-,]page-([0-9]+)$ ]]; then
  TEMPLATE="${BASH_REMATCH[1]}"
  N="${BASH_REMATCH[2]}"
else
  TEMPLATE="${DEFAULT_TEMPLATE:-SUPP_PLUMBER}"
  N="$PAGE"
fi

OUT_DIR="$REPO_ROOT/templates/$TEMPLATE/assets"
mkdir -p "$OUT_DIR"
OUT_ABS="$(cd "$OUT_DIR" && pwd)/page-${N}.svg"

if command -v inkscape &>/dev/null; then INKSCAPE=inkscape
elif [[ -x /Applications/Inkscape.app/Contents/MacOS/inkscape ]]; then INKSCAPE=/Applications/Inkscape.app/Contents/MacOS/inkscape
else echo "Error: Inkscape not found"; exit 1; fi

echo "Exporting page $PAGE -> $OUT_ABS (text as path)"
"$INKSCAPE" --batch-process --pages="$PAGE" --export-text-to-path --export-plain-svg --export-filename="$OUT_ABS" "$INPUT_PDF" 2>/dev/null

FIX="$SCRIPT_DIR/fix-svg-viewbox-612x792.py"
[[ -f "$FIX" ]] && python3 "$FIX" "$OUT_ABS" 2>/dev/null || true
echo "Done: page-${N}.svg"
