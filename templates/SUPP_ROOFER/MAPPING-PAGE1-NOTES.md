# SUPP_ROOFER Page 1 – Mapping vs Netlify Form vs Other Templates

## How page 1 compares with other mapping areas

| Area | Applicant / physical address | Locations |
|------|------------------------------|-----------|
| **ACORD140** (page-1) | `physical_address_1`, `physical_city`, `physical_state`, `physical_zip` (four separate fields) | N/A |
| **ACORD125** (page-1) | `physical_city`, `physical_state`, `physical_zip` | N/A |
| **SUPP_CONTRACTOR** (page-1) | `physical_address_1`, `physical_city_1`, `physical_state`, `physical_zip` | N/A |
| **SUPP_ROOFER** (page-1) | **Now:** `applicant_address`, `applicant_city`, `applicant_state`, `applicant_zip` (same pattern: address + city + state + zip) | **Now:** per location: `location_N_address`, `location_N_city`, `location_N_state`, `location_N_zip` (N = 1, 2, 3) |

So page 1 is aligned with the usual “address, city, state, zip” pattern used in ACORD140 and SUPP_CONTRACTOR.

---

## Netlify Roofer form ↔ page-1 map (field names)

**The map uses the same names as the Netlify form** (form name = map `name`). No backend aliasing needed.

| Map / form name | Notes |
|-----------------|--------|
| `applicant_name`, `applicant_address`, `applicant_city`, `applicant_state`, `applicant_zip` | Match |
| `applicant_phone`, `web_address` | Match |
| `inspection_contact`, `inspection_phone` | Match |
| `policy_period_from`, `to` | Match |
| `location_1_address` … `location_1_zip` (and 2, 3) | Match (form has 4 fields per location) |

---

## Page 1 remap summary

- **Applicant mailing address:** One block was replaced with four fields: `applicant_address`, `applicant_city`, `applicant_state`, `applicant_zip` (positions: address line at y 170; city/state/zip at y 185).
- **Locations 1–3:** Each of `location_1`, `location_2`, `location_3` was replaced with four fields: `location_N_address`, `location_N_city`, `location_N_state`, `location_N_zip` (same row for each location, split into four boxes).

Coordinates are in `base_612x792`. If the PDF layout differs, tweak x/y/w/h in the mapper and re-export.

---

## What was done (by the assistant) vs what you need to do

### What was done (no action needed from you)

1. **`pdf-backend/CID_HomeBase/templates/SUPP_ROOFER/mapping/page-1.map.json`**  
   - Replaced single applicant mailing block with `applicant_address`, `applicant_city`, `applicant_state`, `applicant_zip`.  
   - Replaced `location_1` / `location_2` / `location_3` with `location_N_address`, `_city`, `_state`, `_zip` for N = 1, 2, 3.  
   - Renamed to match the Netlify form: `applicant_name`, `applicant_phone`, `inspection_phone`, `policy_period_from` (so form names = map names).

2. **`roofing-pdf-backend/Netlify/index.html`**  
   - Added `applicant_city`.  
   - Replaced single Location #1 / #2 / #3 inputs with address, city, state, zip fields per location.

3. **This notes file** in the same SUPP_ROOFER template folder.

### What you need to do (so we don’t duplicate)

- **If your single source of truth for templates/mapping is standalone `CID_HomeBase`** (e.g. `~/GitHub/CID_HomeBase`):  
  Copy the updated mapping file into it so the mapper and any other consumers use the same JSON:

  ```bash
  cp /path/to/pdf-backend/CID_HomeBase/templates/SUPP_ROOFER/mapping/page-1.map.json \
     /path/to/CID_HomeBase/templates/SUPP_ROOFER/mapping/page-1.map.json
  ```

  (Replace `/path/to/pdf-backend` and `/path/to/CID_HomeBase` with your real paths, e.g. `~/GitHub/pdf-backend` and `~/GitHub/CID_HomeBase`.)

- **You do not need to** re-enter anything in the CID Click Mapper or manually paste JSON unless you want to tweak positions (x/y/w/h). The JSON in the repo is ready to use.

- **If `pdf-backend` (or `roofing-pdf-backend`) uses `CID_HomeBase` as a git submodule:**  
  After you update the standalone repo, in the backend repo run `git submodule update --remote CID_HomeBase` (or commit the mapping in CID_HomeBase and point the submodule at that commit). Only needed if you keep mapping in standalone and pull it into the backend via submodule.
