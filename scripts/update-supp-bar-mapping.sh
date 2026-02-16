#!/usr/bin/env bash
# Copy page-1 and page-2 mapping JSON into CID_HomeBase SUPP_BAR template.
# Usage:
#   From CID_HomeBase:  ./scripts/update-supp-bar-mapping.sh <dir>
#     Copies <dir>/page-1.map.json and <dir>/page-2.map.json into templates/SUPP_BAR/mapping/
#   Or with two files:  ./scripts/update-supp-bar-mapping.sh <page-1.map.json> <page-2.map.json>

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CID_HOMEBASE="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$CID_HOMEBASE/templates/SUPP_BAR/mapping"

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: SUPP_BAR mapping dir not found: $TARGET_DIR" >&2
  exit 1
fi

if [[ $# -eq 1 ]] && [[ -d "$1" ]]; then
  SRC1="$1/page-1.map.json"
  SRC2="$1/page-2.map.json"
elif [[ $# -eq 2 ]]; then
  SRC1="$1"
  SRC2="$2"
else
  echo "Usage: $0 <dir-with-page-1-and-2.map.json>" >&2
  echo "   or: $0 <page-1.map.json> <page-2.map.json>" >&2
  exit 1
fi

for f in "$SRC1" "$SRC2"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: file not found: $f" >&2
    exit 1
  fi
done

cp "$SRC1" "$TARGET_DIR/page-1.map.json"
cp "$SRC2" "$TARGET_DIR/page-2.map.json"
echo "Updated $TARGET_DIR/page-1.map.json and page-2.map.json from $SRC1 and $SRC2"
