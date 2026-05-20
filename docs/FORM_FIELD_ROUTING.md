# Form field routing — every answer has a destination

**As of:** 2026-05-20  
**Goal:** Every Netlify intake field resolves to **SUPP**, **ACORD**, **both**, **CLIENT_SUBMISSION**, **meta**, or **remarks overflow**.

## How it works

```
Netlify form submit
    ↓
applyFormFieldRouting()  ← src/services/formFieldRoutingService.js
    ↓
maybeMapData() per PDF template  ← src/server.js
    ↓
SUPP + ACORD PDFs + CLIENT_SUBMISSION snapshot
```

| Destination | Meaning |
|-------------|---------|
| **SUPP / ACORD** | Same `name` on form + map JSON (or copy route) |
| **routed** | `formFieldRouting.js` copy / yes-no / AI / roofer % tables |
| **remarks** | No dedicated slot yet — labeled line on SUPP `remarks` |
| **meta** | Analytics / quote product — not on carrier PDFs |
| **CLIENT_SUBMISSION** | Always includes full raw form (automatic) |

Config: `pdf-backend/src/config/formFieldRouting.js`  
Audit: `node CID_HomeBase/scripts/audit-form-routing.js`

## Audit status (all segments)

Run the audit locally — expect **0 client-only gaps**:

| Segment | Form fields | Covered |
|---------|-------------|---------|
| BAR | 117 | 117 |
| Roofer | 159 | 159 |
| Plumber | 82 | 82 |
| HVAC | 77 | 77 |
| Fitness | 77 | 77 |

## Known patterns

### Contractor yes/no (Plumber, HVAC, Fitness)

Form uses short keys (`hire_subs`, `is_licensed`). SUPP uses Society checkbox pairs (`hire_subcontractors_yes` / `_no`). Routing applies on submit.

### Roofer percentages

Form: `commercial_new_construction`, `metal_percent`, …  
SUPP page-1: `fill_28`, `metal`, `pitch_roofs`, … (see `ROOFER_COPY` in config).

### Additional insured

- Block 1: form `ai_name_1` → ACORD `ai_name` + SUPP `ai_name_1` (contractor)
- Block 2: SUPP page-6 on contractor; **bar/roofer** → `remarks` until mapper adds slots

### Bar property (ACORD140)

`business_personal_property` → `building_value` / `building_limit`  
`year_built`, construction checkboxes → `bldg_description` / remarks  
`ComboBox1` (extra auto policies) → remarks

### Gas / boiler (Plumber/HVAC)

Society SUPP maps for these pages are incomplete vs intake form → **remarks overflow** until mapper adds coords.

## Deploy

1. **Render** — deploy `pdf-backend` (routing runs in CID-PDF-API).
2. **HomeBase** — SUPP_ROOFER pages 1–4 synced; bump submodule on Render.
3. **Netlify** — no form renames required for this pass.

## Follow-up (mapper)

- Add dedicated SUPP slots for gas/boiler/roofer safety questions (replace remarks overflow).
- Rename SUPP_ROOFER `fill_*` / `check_box*` to semantic names in maps.
- ACORD130 `producer_email` / `producer_phone` on page-1 (all segments).
