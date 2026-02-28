# CID / RSS GOLD — Session Report (handoff)

**Purpose:** One-page summary so everyone (you, CTO, next session, HVAC launch) is on the same page.

---

## What You Have

- **CID** = Commercial Insurance Direct; multi-segment (Bar, Roofer, Plumber, future HVAC).
- **RSS GOLD** = Reliable, Scalable, Sellable — the canonical pattern. Templates and mapping live **only** in **CID_HomeBase**; segment backends are thin (load from HomeBase, no duplicate templates/PDFs).
- **Canonical paths (locked):**
  - Templates: `CID_HomeBase/templates/<TemplateName>/`
  - Mapping: `CID_HomeBase/templates/<TemplateName>/mapping/page-X.map.json`
  - Assets: `.../assets/*.svg`
  - Segment backends (pdf-backend, plumber-pdf-backend, roofing-pdf-backend) use **CID_HomeBase** as sibling/submodule; production = flattened SVG + map JSON only (no pdf-lib/Puppeteer in deploy).

---

## What We Did This Session

### 1. PDF → Mapper workflow (saves mapping time)
- **Tool:** `CID_HomeBase/tools/mapper/pdf-draft.html` (open in Chrome).
- **Flow:** In Adobe Acrobat run **Prepare Form** on the PDF → save. Open pdf-draft.html → Choose file → Load page → **Extract form fields** → **Open in Mapper**. Mapper opens with draft JSON + **PDF page as background**. Add/rename fields, set multiline, **Copy JSON** → paste into `page-X.map.json`.
- **Inkscape:** Use the **regular** (non–Prepare Form) PDF to export the page as SVG for the asset; save that SVG into the template’s `assets/` after Inkscape. Prepare Form is only for extraction in the draft tool.
- **Mapper:** Rounding to **one decimal place** for all coordinates/dimensions in the output JSON.

### 2. Plumber backend (local run / stability)
- **Gmail:** Env check is lazy; server starts without `GMAIL_USER`/`GMAIL_APP_PASSWORD` (only required when sending email).
- **Crons:** COI and Librarian crons run only when `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are set (`HAS_SUPABASE`); no crash when Supabase is missing locally.
- **CSS:** Plumber loads global CSS from **CID_HomeBase/templates/_shared/styles.css** (no local `templates/` or `styles/`).

### 3. Test scripts (two PDFs only)
- **Script:** `plumber-pdf-backend/scripts/test-two-pdfs.sh` — requests only SUPP_PLUMBER and ACORD125, writes `Supplemental.pdf` and `ACORD125.pdf`, opens both. Does not change PLUMBER_INTAKE.
- **Docs:** `plumber-pdf-backend/scripts/TEST-STEPS.md` and `CID_HomeBase/tools/README.md` describe local test and PDF-draft workflow.

### 4. RSS GOLD backend cleanup (CTO audit / HVAC ready)
- **Bar (pdf-backend):** Removed test PDFs and legacy root `mapping/`.
- **Plumber:** Removed repo PDFs, `_archive/`, `styles/`, `templates/`, `tools/`, `mapping/`, `samples/`, junk files. **Kept** `bible/` (endorsement data). CSS now from HomeBase.
- **Roofer:** Removed Bar scripts (`bar-data-enricher (1).js`, `normalizeBar125 (1).js`), test PDFs, `mapping/`, `pdf/`.
- **Scripts:** `CID_HomeBase/scripts/rss-gold-cleanup.sh` (dry-run by default; `--doit` to run), `rss-gold-commit.sh` to commit all three. Doc: `CID_HomeBase/docs/RSS_GOLD_CLEANUP.md`.
- **Status:** Cleanup run and committed in all three backends (Plumber and Roofer ahead of origin by 1 commit; push when ready).

---

## Key Paths

| What | Where |
|------|--------|
| HomeBase (templates, mapping, tools) | `CID_HomeBase/` |
| PDF-draft tool | `CID_HomeBase/tools/mapper/pdf-draft.html` |
| Mapper | `CID_HomeBase/tools/mapper/mapper.html` |
| Local PDF extraction (optional) | `CID_HomeBase/tools/extract-pdf-fields.js` (local only; not in deploy) |
| Bar backend | `pdf-backend/` |
| Plumber backend | `plumber-pdf-backend/` |
| Roofer backend | `roofing-pdf-backend/` |
| Cleanup scripts | `CID_HomeBase/scripts/rss-gold-cleanup.sh`, `rss-gold-commit.sh` |

---

## One-Line Recap

**RSS GOLD:** HomeBase is canonical; Bar/Plumber/Roofer are cleaned and thin; PDF-draft → Mapper workflow is in place with Prepare Form + Open in Mapper + one-decimal JSON; all set for CTO audit and HVAC launch.

---

*Report generated for handoff. Update this file as you add HVAC or change the pattern.*
