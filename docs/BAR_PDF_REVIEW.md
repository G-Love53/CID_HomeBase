# BAR PDF Review – Mapping & Missing Info

Quick reference from testing the full BAR flow (Netlify form → email with SUPP_BAR + ACORD125, 126, 130, 140).

---

## 1. SUPP_BAR – Page 2 “second column” misalignment

**Issue:** Continuation details (opening plan, prior experience, entertainment, etc.) were rendering in the left column; they should be in the **right** column (details column) on the form.

**Cause:** In `page-2.map.json` all 9 detail fields used `x: 147`. The page-2 SVG has a vertical divider; the right column starts at ~177 in base 612×792.

**Fix applied:** All 9 detail fields’ `x` updated from `147` → `177` in `SUPP_BAR/mapping/page-2.map.json`. Footer fields (sps1_102020_2, page_2_of_2, society_supplemental_continuation) left as-is.

---

## 2. Missing info in boxes (likely causes)

Data is filled only when **payload keys** match mapping **`name`** (see `NETLIFY_FORM_VS_BAR_MAPPING.md`). Common reasons for empty boxes:

- **Form name ≠ mapping name**  
  Example: form sends `premise_address` but mapping expects `premises_address`. Fix on Netlify form or in backend mapping layer.
- **Not sent from form**  
  Example: `date`, `date_2`, agency/agent/code/phone often need to be set by the backend or defaulted.
- **ACORD130 page-1**  
  Repo has `ACORD130/mapping/page-1.map.json` with `"items":[]` and no `fields`. If ACORD130 page-1 is blank, add proper `fields` array (same schema as other ACORDs).

**Next step:** For each specific empty box, note the form label or field (and which PDF/page). Then either:
- Add/rename the form field to match the mapping `name`, or  
- Add a backend alias from form key → mapping name, or  
- Add the field to the mapping if it’s a new box.

---

## 3. ACORDs (125, 126, 130, 140)

- **125, 126, 140:** Have `fields` in mapping; blanks usually mean payload key doesn’t match (e.g. `insured_name` vs `applicant_name`). Use `NETLIFY_FORM_VS_BAR_MAPPING.md` and align form or backend.
- **130:** Page-1 mapping is currently empty (`items:[]`). Populate with correct `fields` when ready to fill page-1.

---

## 4. Netlify form → SUPP_BAR (index form updates)

Applied per user spec:

- **Applicant Name** = contact person → form field `applicant_name`.
- **Business Name/Insured Name** = insured on all SUPP and ACORDs → form field `insured_name` (required). Backend falls back: `insured_name` from `premises_name` if needed.
- **DATE:** No form field; backend sets `date` and `date_2` to today (or `policy_effective_date` if present).
- **Number of employees:** Form sends `number_of_employees`; added to SUPP_BAR page-1 map at (334, 186) so it appears in the correct box.
- **Q17 (Smoker within 10ft):** Same value maps to SUPP “Solid Fuel 10ft from unit” via `full_limited_none12_solid_fuel_10_ft_from_unit`. Form sets hidden from Q17 select; backend aliases from `solid_fuel_smoker_grill_within_10_ft` if missing.
- **Q18 (Any cooking surfaces not protected):** Maps to SUPP “13. Any cooking” via `13_any_cooking_s`. Form sets hidden from Q18 select; backend aliases from `ul_suppression_over_cooking` if missing.
- **Other activities (form Q20):** Already maps to SUPP “15. Other Recreational Activities” (`15_other_recreational_activities_beyond_listed`, `recreational_details`).
- **Page 2:** Detail fields use x=177 so they fall in the right column; each row’s y is unchanged.

---

## 5. Lock and move on

After the page-2 X fix and form/mapping updates, re-run the two bashes (HomeBase push → backend submodule update + push) and redeploy. Then lock this round and move on.
