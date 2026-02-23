# Netlify Form vs BAR Mapping (SUPP_BAR + ACORDs)

**Canonical names are ACORD.** The form and SUPP_BAR use ACORD-consistent field names where they overlap (e.g. `insured_name`, `physical_address_1`, `physical_city`, `physical_state`, `physical_zip`, `producer_email`, `policy_effective_date`, `business_website`). The backend builds SUPP-only keys (e.g. `premises_address`) from those when needed.

The pdf-backend fills PDFs by matching **payload keys** to mapping **`name`** values (`data[key]` in svg-engine). The Netlify form’s `name` attributes match ACORD mapping names where they represent the same field.

Below: **SUPP_BAR** (page-1 + page-2) and **ACORD** usage. Changes are what to do **on the Netlify form** so submitted data aligns with the mapping.

---

## 1. SUPP_BAR – Field roles (Bar index form)

- **Applicant Name (Contact):** form field `applicant_name` — the person/contact.
- **Business Name/Insured Name:** form field `insured_name` — this is the insured on all SUPP and ACORDs. Required.
- **DATE:** No form field; backend sets `date` and `date_2` to today (or policy_effective_date).

## 2. SUPP_BAR – Direct name matches (no change)

These already match between form and mapping:

- `applicant_name`
- `insured_name` (Business Name/Insured Name on form)
- `square_footage`
- `number_of_employees` (form Q9; also added to page-1 map)
- `food_sales`
- `alcohol_sales`
- `total_sales`
- `entertainment_details`
- `recreational_details`
- `shuttle_explanation`

---

## 3. SUPP_BAR – Change on Netlify form

Apply these renames so the form sends the keys the mapping expects.

| Netlify form (current) | SUPP_BAR mapping expects | Note |
|------------------------|--------------------------|------|
| `premise_address`      | `premises_address`       | Single full-address field on PDF. Either rename and combine address in JS, or keep one input and name it `premises_address`. |
| `premise_city`         | (none)                   | Mapping has only `premises_address`. Combine into `premises_address` before submit, or add a backend step that builds it. |
| `premise_state`        | (none)                   | Same as above. |
| `premise_zip`          | (none)                   | Same as above. |
| `open_60_days`         | `1_open_for_business_now_or_within_60_days` | Yes/No for “open now or within 60 days”. |
| `open_60_days_details` | `if_no_explain` (page-1) **and** `opening_plan_details` (page-2) | Mapping has both; page-2 is the big “details” box. Use same value for both, or send `opening_plan_details` for the long text. |
| `ownership_experience`  | `2_at_least_3_years_restaurantbar_ownership_in_last_5_years` and `2_at_least_3_years_restaurantbar_ownership_in_last_5_years_2` | Two positions on form; both get Yes/No. Map form’s single select to both keys. |
| `ownership_experience_details_yes` | `prior_experience_details` (page-2) | Long text on page-2. |
| `ownership_experience_details_no`  | `prior_experience_details` (page-2) | Same; use one or the other depending on Yes/No. |
| `num_employees`        | `number_of_employees`    | Rename input to `number_of_employees`. |
| `counter_service`      | `counter_serv`           | Rename to `counter_serv` (abbrev on form). |
| `cooking_level_full`   | `full`                   | Checkbox. Rename to `full`. |
| `cooking_level_limited`| `limited`                | Rename to `limited`. |
| `cooking_level_non`    | `none`                   | Rename to `none`. |
| `Percent_Alcohol`      | (no direct match)        | Mapping has `total_sales_2`; keep calculated % in JS and also send as a key backend expects if you add one, or leave as-is if only for display. |

---

## 4. SUPP_BAR – Q17 / Q18 → SUPP boxes

- **Q17 (Smoker within 10ft of building):** form `solid_fuel_smoker_grill_within_10_ft`. Also copied to `full_limited_none12_solid_fuel_10_ft_from_unit` (SUPP “Solid Fuel 10ft from unit”) via form hidden + backend alias.
- **Q18 (Any cooking surfaces not protected by UL300):** form `ul_suppression_over_cooking`. Also sent as `13_any_cooking_s` (SUPP “13. Any cooking”) via form hidden + backend alias.
- **Q20 Other activities:** maps to SUPP “15. Other Recreational Activities” (`15_other_recreational_activities_beyond_listed`, `recreational_details`).

## 5. SUPP_BAR – Generic ComboBox / TextField → semantic mapping names

Mapping uses semantic names; the form currently uses generic IDs. Rename (or map in submit handler) as below.

| Netlify form (current) | SUPP_BAR mapping expects |
|------------------------|--------------------------|
| `ComboBox22`           | `background_checks`      |
| `ComboBox23`           | `armed`                  |
| `ComboBox24`           | `conflictres_trained`    |
| `ComboBox13`           | `insuredowned_autos`     |
| `ComboBox14`           | `employee_autos`         |
| `ComboBox15`           | `3rdparty_delivery`      |
| `TextField0`            | `delivery_sales_insuredemp_autos` |
| `ComboBox16`           | `3rdparty_deliverymore_than_20_of_location_sales` (Yes/No) |
| `TextField12`          | `if_yes_explai` (page-1) **and** `delivery_20_explanation` (page-2) – use same value for both |
| `ComboBox17`           | (radius > 5 miles – no separate Yes/No key in mapping; explanation only) |
| `TextField11`          | `radius_5_miles_explanation` (page-2) |
| `ComboBox18`           | `hours_past_10_pm` (Yes/No) |
| `TextField13`          | `if_yes_explain` (page-1) **and** `after_10pm_explanation` (page-2) |
| `ComboBox19`           | `18_if_auto_coverage_is_rated_shuttle_servic` (shuttle Yes/No) |
| `ComboBox1`             | (additional auto policies – no matching key in SUPP_BAR mapping; omit or add to mapping if needed) |
| `liquor_lapse`         | `19_any_liquor_law_violations_in_last_3_years` |
| `liquor_claims`        | `if_yes_describe`        |

For any ComboBox/TextField not listed, check `SUPP_BAR/mapping/page-1.map.json` and `page-2.map.json` for the exact `"name"` and align the form name or submit payload.

---

## 6. SUPP_BAR – Page-2 “details” fields

These are the big text areas on page-2; mapping names and suggested form names:

| Mapping name (page-2)   | Netlify action |
|------------------------|----------------|
| `opening_plan_details`  | Use value from “open 60 days” details (e.g. `open_60_days_details` → send as `opening_plan_details`). |
| `prior_experience_details` | Use ownership experience details (yes or no) and send as `prior_experience_details`. |
| `entertainment_details`| Already matches. |
| `recreational_details` | Already matches. |
| `delivery_20_explanation` | “Delivery >20%” explain (currently `TextField12`). |
| `radius_5_miles_explanation` | “Radius >5 miles” explain (currently `TextField11`). |
| `after_10pm_explanation` | “Delivery past 10pm” explain (currently `TextField13`). |
| `shuttle_explanation`  | Already matches. |
| `smoker_grill_notes_cont` | No obvious form field; add a textarea/input if you want to fill this, and name it `smoker_grill_notes_cont`. |

---

## 7. SUPP_BAR – Other mapping fields (form or backend)

These mapping names may need to be sent from the form or set by the backend (e.g. date, remarks, agency):

- `date` / `date_2` – e.g. effective date or today.
- `if_no_explain`, `if_no_prior_experie` – “If no” explain text (can mirror open 60 / ownership details).
- `8_manufacture_alcohol`, `if_yes_more_than_25_for_onpremise`, `if_yes_more_than_25_for_onpremise_2` – alcohol manufacturing / >25% on premises.
- `11_infuse_products_with_cannabis`, solid fuel / cooking / extinguisher / UL300 fields – match to your current form questions and rename to these mapping names.
- `remarks`, `agency`, `agent`, `phone`, `code`, etc. – usually backend or default values.

**Solid fuel / smoker (form → mapping):**  
- `solid_fuel` → `solid_fuel_smoker_grill_within_10_ft` (or keep and add backend alias)  
- `professionally_installed` → `unit_professionally_installed`  
- `cleaned_scraped_weekly` → `scraped_weekly`  
- `vent_cleaned_monthly` → `ventexhaust_inspectedcleaned_monthly`  
- `ashes_removed_daily` → `ashes_removed_daily_into_a_metal_container`  
- `storage_10_feet` → `is_fuel_pellets_wood_more_than_10_from_unit`  
- `hood_ul300` → `hood_duct_protection` (or `ul_suppression_over_cooking` – check PDF layout)  
- `fire_extinguisher_20_feet` → `class_k_or_2a_extinguisher_within_20_ft`  
- `non_UL300` → `ul_suppression_over_cooking` or similar (check mapping)  
- `entertainment_other` → `14_any_entertainment_other_than_bg_musickaraoketrivia`  
- `recreational_activites` → `15_other_recreational_activities_beyond_listed` or `15_other_recreational_activities_beyond_listed_2`  
- `delivery_offered` → `17_offer_delivery`  
- `infused_with_cannabis` → `11_infuse_products_with_cannabis`  
- `regularly_maintained` → can map to the maintenance checkboxes or a single key if one exists.

Either add matching inputs on the form or ensure the backend adds these keys before calling the SVG engine.

---

## 8. ACORD (Universal) – Bar bundle

Bar bundle uses **ACORD125, ACORD126, ACORD130, ACORD140** (not ACORD25; ACORD25 is in COI_STANDARD). Those templates have their own mapping files with names like:

- **ACORD125:** `insured_name`, `physical_address_1`, `physical_city`, `physical_state`, `physical_zip`, `fein`, `sic`, `naics`, etc.

If the same Netlify form is used to drive both SUPP_BAR and ACORDs, you have two options:

1. **Same keys:** Change ACORD mapping to use the same names as the form (e.g. `applicant_name` → insured name, `premises_address` → address). Then one payload fits both.
2. **Different keys:** Keep ACORD mapping as-is and add a server-side or client-side mapping from form names to ACORD names (e.g. `applicant_name` → `insured_name`, `premises_address` → `physical_address_1` + city/state/zip).

If you prefer “make changes on the Netlify form side,” then align form names with **SUPP_BAR** as above, and either (a) align ACORD mapping names with the same form names where they mean the same thing, or (b) keep one small mapping layer from form → ACORD keys only for the fields that differ.

---

## Summary

- **Rename on Netlify form** so these match SUPP_BAR mapping:  
  `premise_*` → `premises_address` (and combine address), `open_60_days` → `1_open_for_business_now_or_within_60_days`, `num_employees` → `number_of_employees`, `counter_service` → `counter_serv`, `cooking_level_*` → `full` / `limited` / `none`, and the ComboBox/TextField names to the semantic names in the table above.
- **Page-2 details:** Send `opening_plan_details`, `prior_experience_details`, `delivery_20_explanation`, `radius_5_miles_explanation`, `after_10pm_explanation` (and optionally `smoker_grill_notes_cont`) with the correct names.
- **ACORDs:** Either use the same field names as SUPP_BAR where possible (Universal ACORD), or add a small mapping from form names to ACORD mapping names for the Bar bundle.

After these changes, the Netlify form will match the BAR mapping (SUPP_BAR + ACORDs) so the backend can fill PDFs without extra mapping logic.
