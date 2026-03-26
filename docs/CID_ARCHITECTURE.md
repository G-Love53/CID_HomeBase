## CID-PDF-API — CID Architecture Notes (S1-S6)

> **Canonical location:** `CID-docs/CID_ARCHITECTURE.md` outside segment repos. This local file is a synced copy.

## Core Architecture Rule (Locked)

- `pdf-backend` (Render service: `CID-PDF-API`) is the **single backend** for:
  - Operator UI and dashboard
  - S4 extraction review
  - S5 packet builder
  - S6 bind flow, webhooks, policy creation
  - Gmail poller and quote ingestion
- Segment repos (`plumber-pdf-backend`, `roofing-pdf-backend`, `hvac-pdf-backend`) are intake/static wrappers only.

## End-to-End Flow

1. **Capture (S1-S3)**  
   Netlify intake posts to `/submit-quote` with `bundle_id`, `segment`, and `formData`.
2. **Submit / Persist**  
   API writes `clients`, `submissions`, `timeline_events`; generates ACORD/SUPP PDFs and `CLIENT_SUBMISSION` ("questions answered") PDF.
3. **Carrier outreach**  
   Outbound subject must include bracketed CID token (`[CID-SEG-YYYYMMDD-######]`).
4. **Carrier reply ingestion (poller)**  
   Poller scans `INBOX + UNREAD`, processes only mail with **CID token + PDF attachment**, writes `carrier_messages/documents/quotes/work_queue_items`, auto-labels `carrier-quotes`.
5. **S4 extraction review**  
   Queue items in `work_queue_items` (`extraction_review`) flow through review/approve/dismiss.
6. **S5 packet build**  
   Packet combines sales letter + summary + carrier quote and sends to client.
7. **S6 bind**  
   BoldSign bind request is created; signed file finalization creates `policies`.

## Current Production Invariants

- **Duplicate intake logic (updated):**
  - Same email alone is **not** duplicate.
  - Duplicate requires matching business identity (and zip when present), or business+zip fallback when email missing.
- **AI sales letter (S5):**
  - Primary: Claude (`ANTHROPIC_API_KEY`)
  - Fallback: Gemini (`GEMINI_API_KEY`)
  - Last resort: deterministic template letter
- **Bind signing document (S6):**
  - Signs a centralized, segment-branded bind-confirmation PDF template
  - Stable signature placement via `signature_template=bind_confirmation_v1`
  - Placement env overrides: `BOLDSIGN_BIND_CONFIRMATION_SIGNATURE_X/Y/WIDTH/HEIGHT`

## Operator Surfaces

- `/operator` (home + segment switcher + today drilldowns)
- `/operator/extraction-review` (S4 queue/detail, includes dismiss)
- `/operator/packet-builder` (S5 queue/detail)
- `/operator/bind` (S6 queue/detail)

## Persistence Spine

- `submissions` (`submission_public_id`)
- `carrier_messages`
- `quotes`, `quote_extractions`, `quote_packets`
- `documents` (R2-backed originals and generated artifacts)
- `work_queue_items`
- `bind_requests`, `policies`
- `timeline_events`, `signature_events`
