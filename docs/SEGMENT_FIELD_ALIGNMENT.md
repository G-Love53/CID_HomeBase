# Segment field alignment — ACORD is the TRUTH

**As of:** 2026-05-20  
**Segments:** Roofer, Plumber, HVAC, Fitness (+ BAR in [`BAR_FIELD_ALIGNMENT.md`](./BAR_FIELD_ALIGNMENT.md))

## Rules

1. **ACORD** `templates/ACORD*/mapping/*.map.json` field `name` values are canonical.
2. **SUPP** maps rename to match ACORD when the same data appears on both PDFs.
3. **Netlify forms** use the same `name` as SUPP + ACORD for shared fields.
4. **`maybeMapData()`** (`pdf-backend/src/server.js`) — legacy / third-party aliases only (Coterie, old field names).
5. **SUPP-only** questions keep SUPP keys; no forced ACORD slot.

## Canonical core fields (all segments)

| Concept | ACORD key |
|---------|-----------|
| Insured / business | `insured_name` |
| Contact person | `applicant_name` |
| Street | `physical_address_1` |
| City / state / zip | `physical_city`, `physical_state`, `physical_zip` |
| Location 1–4 (125 p2) | `premise_address_1` … `premise_address_4`, `premise_city_1` … |
| Square feet loc 1 | `total_squarefeet_1` |
| Phone / website | `business_phone`, `business_website` |
| Effective date | `policy_effective_date`, `date` |
| WC (130) | `num_ft_employees`, `num_pt_employees`, `annual_payroll` |
| Producer | `producer_email`, `producer_phone` |

## Batch 1 — shipped 2026-05-20

### Roofer (`SUPP_ROOFER` + `roofing-pdf-backend/Netlify`)

| Was | Now (ACORD-aligned) |
|-----|---------------------|
| `web_address` | `business_website` |
| `applicant_phone` | `business_phone` |
| `policy_period_from` | `policy_effective_date` |
| `location_1_address` | `premise_address_1` |
| `location_1_city` | `premise_city_1` |
| `location_1_state` | `physical_state` |
| `location_1_zip` | `physical_zip` |
| `location_2_*` / `location_3_*` address+city | `premise_address_2/3`, `premise_city_2/3` |

`applicant_address` / `applicant_city` / … remain **SUPP-only** (mailing block on supplement).

### Plumber + HVAC (forms + SUPP page-5)

| Was | Now |
|-----|-----|
| Form `web_address` | `business_website` (matches SUPP p1 + ACORD) |
| SUPP `projected_revenue` | `projected_gross_revenue` (matches form) |

Forms already use `physical_address_1`, `physical_city`, `insured_name`, `applicant_name`, `wc_*` → aliased to `num_ft_employees` / `annual_payroll` on ACORD130.

### Backend (`applyUniversalCanonicalFields`)

Runs for every template render: legacy → canonical, location → premise/physical, `mailing_address` from physical on SUPP contractor templates, contractor `projected_gross_revenue` → ACORD126 `exposure_1` / `grosssales_1`.

## curl smoke tests

**Roofer:**

```bash
curl -sS -X POST "https://cid-pdf-api.onrender.com/submit-quote" \
  -H "Content-Type: application/json" \
  -d '{
    "bundle_id": "ROOFER_INTAKE",
    "segment": "roofer",
    "force_resubmit": true,
    "formData": {
      "applicant_name": "Test Roofer",
      "insured_name": "Test Roofing LLC",
      "applicant_address": "100 Mail St",
      "applicant_city": "Denver",
      "applicant_state": "CO",
      "applicant_zip": "80202",
      "premise_address_1": "200 Job Site Rd",
      "premise_city_1": "Denver",
      "physical_state": "CO",
      "physical_zip": "80203",
      "business_phone": "3035550100",
      "contact_email": "test@example.com",
      "policy_effective_date": "2026-06-01"
    }
  }'
```

**Plumber:**

```bash
curl -sS -X POST "https://cid-pdf-api.onrender.com/submit-quote" \
  -H "Content-Type: application/json" \
  -d '{
    "bundle_id": "PLUMBER_INTAKE",
    "segment": "plumber",
    "force_resubmit": true,
    "formData": {
      "applicant_name": "Test Plumber",
      "insured_name": "Test Plumbing LLC",
      "physical_address_1": "123 Main St",
      "physical_city": "Denver",
      "physical_state": "CO",
      "physical_zip": "80202",
      "business_phone": "3035550100",
      "contact_email": "test@example.com",
      "business_website": "https://example.com",
      "projected_gross_revenue": "750000"
    }
  }'
```

**HVAC:** same as plumber with `"bundle_id": "HVAC_INTAKE"`, `"segment": "hvac"`.

## Queued (Batch 2+)

- BAR: `premises_address` → split `physical_*`; `insured_name` on form vs `premises_name`
- ACORD130: add `producer_email` / `producer_phone` on page-1 map (all segments)
- Fitness: same pass as plumber/hvac Netlify + SUPP_FITNESS
- AI blocks: form `ai_name_1` ↔ ACORD `ai_name` (partially in maybeMapData today)
