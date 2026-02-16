# RSS GOLD — Backend cleanup for CTO audit & HVAC launch

**Goal:** Each segment backend (Bar, Plumber, Roofer) is thin, no cruft, no duplicate templates/mapping. Canonical truth: **CID_HomeBase** (templates, mapping, tools). Backends only: `src/`, `config/`, `scripts/`, `package.json`, `Dockerfile`, `README`, optional `netlify/`, and **CID_HomeBase** as submodule.

---

## Status (your assessment)

| Backend | Status | Notes |
|--------|--------|--------|
| **CID_HomeBase** | ✅ Great | Single source of truth; no change. |
| **Bar (pdf-backend)** | ✅ Real close | Remove test PDFs, legacy `mapping/` if unused. |
| **Plumber** | 🔴 Out of control | PDFs in repo, _archive, duplicate templates/tools/mapping, styles; align css to HomeBase. |
| **Roofer** | 🟡 In between | Bar files in repo (`bar-data-enricher (1).js`, `normalizeBar125 (1).js`), test PDFs; remove. |

---

## What to remove (by repo)

### Bar (pdf-backend)
- **Root:** `BAR_acord125_p1_test.pdf`, `acord_test.pdf` (already in .gitignore; remove from git).
- **mapping/** — Legacy JSON at repo root; templates use `CID_HomeBase/templates/<Name>/mapping/`. Remove root `mapping/` after confirming no imports reference it.

### Plumber (plumber-pdf-backend)
- **Root:** All `*.pdf` (remove from git; keep in .gitignore).
- **Root:** `Universal.code-search`, `....` (junk files).
- **_archive/** — Old generated PDFs; not needed in repo.
- **styles/** — `print.css`; CSS now from CID_HomeBase (see code change below).
- **templates/** — Duplicate of HomeBase; server uses `CID_HomeBase/templates/`. Remove after fixing `src/utils/css.js` to load from HomeBase.
- **tools/** — Mapper lives in HomeBase `tools/mapper/`; remove local copy.
- **mapping/** — Legacy root mapping; server uses per-template mapping in HomeBase. Remove.
- **samples/** — If only sample PDFs/data, remove or keep one `sample-data.json` at root if scripts need it.
- **Keep:** `bible/` (endorsement catalog/rules used by `src/services/endorsements/`).

### Roofer (roofing-pdf-backend)
- **Root:** `bar-data-enricher (1).js`, `normalizeBar125 (1).js` — Bar code; does not belong in Roofer.
- **Root:** All `*.pdf` (remove from git; add to .gitignore if missing).
- **mapping/** — If legacy (templates from HomeBase), remove.
- **pdf/** — If just output/test PDFs, remove.

---

## Code change required (Plumber only)

**File:** `plumber-pdf-backend/src/utils/css.js`  
**Current:** Loads from `../../templates/assets/common/global-print.css` (local).  
**Change:** Load from CID_HomeBase like Bar: `CID_HomeBase/templates/_shared/styles.css` (or `_SHARED` to match Bar’s forms.json).

After this, Plumber no longer needs local `templates/` or `styles/`.

---

## Step-by-step bash (run from your machine)

**1. Backup (optional but recommended)**  
```bash
cd /Users/newmacminim4/GitHub
cp -R plumber-pdf-backend plumber-pdf-backend.pre-cleanup
cp -R roofing-pdf-backend roofing-pdf-backend.pre-cleanup
cp -R pdf-backend pdf-backend.pre-cleanup
```

**2. Bar (pdf-backend)**  
```bash
cd /Users/newmacminim4/GitHub/pdf-backend
git rm -f BAR_acord125_p1_test.pdf acord_test.pdf 2>/dev/null || true
# If mapping/ is unused:
# git rm -rf mapping
git status
```

**3. Plumber — fix CSS first, then remove cruft**  
```bash
cd /Users/newmacminim4/GitHub/plumber-pdf-backend
# Fix css.js to use HomeBase (see code change above)
git rm -f *.pdf Universal.code-search "...." 2>/dev/null || true
git rm -rf _archive styles templates tools mapping samples 2>/dev/null || true
git status
```

**4. Roofer**  
```bash
cd /Users/newmacminim4/GitHub/roofing-pdf-backend
git rm -f "bar-data-enricher (1).js" "normalizeBar125 (1).js" 2>/dev/null || true
git rm -f *.pdf 2>/dev/null || true
git rm -rf mapping pdf 2>/dev/null || true
git status
```

**5. Ensure .gitignore (all three)**  
- Bar: already has `*.pdf`.  
- Plumber: already has `*.pdf`.  
- Roofer: add `*.pdf` if missing.

**6. Commit per repo**  
```bash
cd /Users/newmacminim4/GitHub/pdf-backend
git add -A && git commit -m "RSS GOLD: remove test PDFs from repo"

cd /Users/newmacminim4/GitHub/plumber-pdf-backend
git add -A && git commit -m "RSS GOLD: remove cruft, align CSS to HomeBase"

cd /Users/newmacminim4/GitHub/roofing-pdf-backend
git add -A && git commit -m "RSS GOLD: remove Bar scripts and test PDFs"
```

---

## After cleanup (target layout)

Each backend root should look like:
- `.git`, `.gitignore`, `.gitmodules` (if using CID_HomeBase submodule)
- `CID_HomeBase/` (submodule)
- `src/`
- `scripts/`
- `package.json`, `package-lock.json`
- `Dockerfile`
- `README.md`
- `sample-data.json` (if still used)
- `netlify/` (Bar only, if used)
- **Plumber only:** `bible/` (endorsement data)

No PDFs, no local `mapping/` or `templates/`, no Bar files in Roofer, no _archive/bible-cruft in Plumber (keep `bible/04_ENDORSEMENTS` only).
