#!/usr/bin/env python3
"""Convert 816x1056 viewBox to 612x792 (wrap content in scale(0.75)). Usage: python3 fix-svg-viewbox-612x792.py <file.svg>"""
import re, sys
if len(sys.argv) != 2: sys.exit("Usage: fix-svg-viewbox-612x792.py <file.svg>")
path = sys.argv[1]
s = open(path, encoding="utf-8").read()
m = re.search(r'<svg[^>]*>', s, re.DOTALL)
if not m or ('viewBox="0 0 816 1056"' not in m.group(0) and 'width="816"' not in m.group(0)):
    sys.exit(0)
s = re.sub(r'\bwidth="816"\b', 'width="612"', s, count=1)
s = re.sub(r'\bheight="1056"\b', 'height="792"', s, count=1)
s = re.sub(r'\bviewBox="0 0 816 1056"\b', 'viewBox="0 0 612 792"', s, count=1)
m2 = re.search(r'<svg[^>]*>', s, re.DOTALL)
end = m2.end()
s = s[:end] + "\n  <g transform=\"scale(0.75)\">" + s[end:]
last = s.rfind("</svg>")
s = s[:last] + "  </g>\n" + s[last:]
open(path, "w", encoding="utf-8").write(s)
