# CID HomeBase tools (local only)

**These tools and any 3rd‑party deps (e.g. pdf-lib) are for local mapping only.**  
They are not used in Render, Git CI, or Puppeteer. We keep them out of the deploy pipeline.

**Production:** Form output is still **flattened SVG + map JSON** only. The segment backends (pdf-backend, roofing-pdf-backend, plumber-pdf-backend) load templates from HomeBase (`templates/<Name>/assets/*.svg`, `templates/<Name>/mapping/page-X.map.json`) and render via the SVG engine—no pdf-lib, no Puppeteer.

- **mapper/** – Manual click mapper (HTML/JS only; no extra deps). Load SVG background, place fields, copy/apply JSON.
- **mapper/pdf-draft.html** – PDF draft tool (open in Chrome): load a PDF page → Extract form fields → draft cid.map.v1 JSON → **Open in Mapper** opens the mapper with that JSON applied and the PDF page as background so you can name fields, set multiline, tweak, then copy into page-X.map.json. Asset (SVG) still comes from Inkscape; save it after Inkscape like now.

**Workflow that works:** (1) In Adobe Acrobat, run **Prepare Form** on the PDF so it has fillable AcroForm fields, then save. (2) Open **pdf-draft.html** in Chrome (e.g. `open …/tools/mapper/pdf-draft.html`). (3) Choose file → Load page → Extract form fields → **Open in Mapper**. (4) In Mapper: add/rename fields, adjust types, copy JSON and paste into the mapping file as before.
- **extract-pdf-fields.js** – Optional local helper: reads a PDF’s AcroForm field names/types and prints draft map JSON. Run with `npm run extract-pdf` (requires `npm install` in this folder). Output is for pasting into the mapper to tweak; the actual templates remain flattened SVGs and the map JSONs you save from the mapper.
