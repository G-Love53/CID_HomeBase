# BAR field alignment — ACORD is the TRUTH

**As of:** 2026-05-20  
**Scope:** BAR intake bundle — `SUPP_BAR` + `ACORD125` + `ACORD126` + `ACORD130` + `ACORD140`  
**Goal:** One canonical field `name` per concept across all PDF maps; supplements and Netlify forms follow ACORD names.

---

## Rules (locked)

| Rule | Detail |
|------|--------|
| **TRUTH** | `CID_HomeBase/templates/ACORD*/mapping/*.map.json` field `name` values |
| **SUPP** | Rename SUPP map keys to match ACORD when the same data appears on both |
| **Forms** | Built from SUPP questions + any ACORD-only questions; form `name` = map `name` |
| **Third parties** | `maybeMapData()` in `pdf-backend` aliases external keys (e.g. Coterie) → canonical ACORD names |
| **SUPP-only** | Bar-specific questions (liquor, solid fuel, entertainment, …) keep SUPP-only keys — no ACORD slot |
| **Hard X** | Backend BAR block auto-ticks coverage lines on ACORD125 — not part of this alignment |
| **Test** | Visual PDF review + `curl` submit against CID-PDF-API |

**Repo flow:** Edit **`CID_HomeBase`** (standalone + submodule) → bump **`pdf-backend`** submodule → **`bar-pdf-backend`** Netlify form when form names change.

---

## Workflow

```
ACORD page maps (TRUTH)
    ↓ same names
SUPP_BAR maps
    ↓ same names (+ SUPP-only fields)
Netlify BAR form
    ↓ optional
maybeMapData (Coterie / legacy aliases only)
```

---

## Batch 1 — Core location & identity (in progress)

| Concept | Canonical key (ACORD) | SUPP_BAR (before) | Netlify form | ACORD pages |
|---------|----------------------|-------------------|--------------|-------------|
| Insured / business name | `insured_name` | `insured_name` | `premises_name` (+ alias) | 125/126/130/140 p1 |
| Contact person | `applicant_name` | — | `applicant_name` | 125 p1, 130 p1 |
| Street address | `physical_address_1` | `premises_address` (combined) | `premise_address` | 125/130/140 |
| City / state / zip | `physical_city`, `physical_state`, `physical_zip` | (in `premises_address`) | `premise_*` | 125/130/140 |
| Square feet (loc 1) | `total_squarefeet_1` | ~~`square_footage`~~ → **fixed** | `total_squarefeet_1` | 125 p2 (`_1`–`_4`) |
| Effective date | `policy_effective_date` / `date` | `date`, `date_2` | `effective_date` | all |
| Producer email/phone | `producer_email`, `producer_phone` | — | backend default | 125 p1; **130 missing** |
| Agency email/phone | `agency_email`, `agency_phone` | — | backend default | 130 p1/p2 |

---

## Batch 2 — Property & operations (queued)

- `year_built`, `num_stories` / `number_of_stories`, `percent_sprinker` / `percent_sprinkler`
- `business_personal_property`, `building_quote`, construction checkboxes
- `fulltime_1` / `number_of_employees`, sales (`food_sales`, `alcohol_sales`, `annual_revenue_1`, `total_sales`)

---

## Batch 3 — BAR SUPP-only (no ACORD rename)

Liquor, cooking, solid fuel, delivery, entertainment, AI blocks — keep SUPP keys; map to ACORD only where a slot exists (e.g. remarks).

---

## Known gaps

| Item | Status |
|------|--------|
| `square_footage` on SUPP_BAR p1 | **Renamed → `total_squarefeet_1`** (Batch 1) |
| ACORD130 `producer_email` / `producer_phone` | **Missing** — add to page-1 map (mapper + SVG coords) |
| ACORD130 page-1 | Has 27 fields; older doc said empty — verify coords vs SVG |
| `food_sales` / `alcohol_sales` on ACORD | SUPP-only today; may go to ACORD125 remarks or exposure fields |
| Netlify `premises_name` vs `insured_name` | Form still sends `premises_name`; backend aliases |

---

## curl smoke (BAR)

```bash
curl -sS -X POST "https://cid-pdf-api.onrender.com/submit-quote" \
  -H "Content-Type: application/json" \
  -d '{"segment":"bar","sourceDomain":"alignment-test","rawSubmission":{"applicant_name":"Test Contact","premises_name":"Test Bar LLC","premise_address":"123 Main St","premise_city":"Denver","premise_state":"CO","premise_zip":"80202","contact_email":"test@example.com","business_phone":"3035550100","effective_date":"2026-06-01","total_squarefeet_1":"2500","food_sales":"500000","alcohol_sales":"300000"}}'
```

Visual: open returned PDFs or email attachment; confirm `total_squarefeet_1` on SUPP p1 + ACORD125 p2 loc 1.
