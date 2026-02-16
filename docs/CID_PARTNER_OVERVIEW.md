# Commercial Insurance Direct — Platform Overview

**One- to two-page overview for partners (CTO, VP Sales).**

---

## What We Built

**Commercial Insurance Direct (CID)** is a multi-segment commercial insurance distribution platform. We generate carrier-ready application packets (ACORD forms + supplemental applications), Certificates of Insurance (COI), and support bind and post-bind workflows — by segment, with one canonical template and mapping engine.

**Segments today:** Bar, Roofer, Plumber. **Next:** HVAC and additional verticals on the same stack.

---

## How It Works (End to End)

1. **Capture** — Consumer or agent completes a segment-specific intake (e.g. Netlify form or CID App).
2. **Submit** — Request hits the segment backend (Bar, Roofer, or Plumber) with a bundle ID and form data.
3. **Render** — Backend loads templates and mapping from **CID_HomeBase**, fills fields (text, checkboxes) onto SVG assets, and produces PDFs (no third-party PDF SDKs in production).
4. **Deliver** — Packet is emailed to the segment quote address (Gmail API). COI requests are processed via Supabase and the same render pipeline; optional AI (Famous AI) and services layer support smarter forms and COI.
5. **Operate** — Supabase backs COI queue, carrier resources, and segment data; cron workers and optional bind/inbox flows complete the lifecycle.

One code pattern per segment; only config and segment-specific content change.

---

## Tech Stack (What’s in the Build)

| Layer | Technology |
|-------|------------|
| **Front-end / intake** | CID App, Netlify forms, segment-specific forms |
| **AI / intelligence** | Famous AI (conversation, enrichment) |
| **Segment backends** | Node.js (Express), Render (Docker); one repo per segment (pdf-backend, plumber-pdf-backend, roofing-pdf-backend) |
| **Templates & mapping** | **CID_HomeBase** — single source of truth: SVG assets, page-by-page field mapping (cid.map.v1), shared styles |
| **Rendering** | SVG-first engine: inject data into SVG, print to PDF (Puppeteer/Chromium in controlled env); no Adobe SDKs, no per-segment template drift |
| **Data & workflows** | Supabase (COI queue, carrier resources, segment data); Gmail API for delivery |
| **COI service** | Request in → queue → render ACORD + attachments → email; endorsement “bible” and rules for normalization |
| **Deploy** | Render (backends), Netlify (forms/app); CID_HomeBase as submodule or sibling for templates |

Everything is built so new segments (e.g. HVAC) clone the same backend pattern and point at HomeBase — no duplicate template sets, no scattered mapping logic.

---

## Why It’s Built Right: RSS GOLD

We run a **single canonical pattern (RSS GOLD)** across segments:

- **Reliable** — One template and mapping definition per form; same 612×792 coordinate contract everywhere; no “which repo has the real ACORD125?”
- **Scalable** — Add a segment by adding a backend repo + config and reusing HomeBase templates and tooling.
- **Sellable** — Clean separation: partners see a clear platform (intake → PDFs → COI → bind), thin backends, and a professional mapping/template workflow.

Templates and mapping live **only** in **CID_HomeBase**. Segment backends do not duplicate PDFs, SVGs, or mapping JSON; they resolve everything from HomeBase. Production rendering is **flattened SVG + map JSON** — no dependency on consumer PDF libraries in the deploy path.

---

## The Mapper: Our Secret Weapon

Building and maintaining form mappings used to mean manual placement and fragile coordinates. We changed that.

- **Click Mapper** — Browser-based tool (open in Chrome). Load the form as an SVG background (from Inkscape), click to place fields, set names and types (text, multiline, checkbox). Output is **cid.map.v1** JSON — the same format the render engine uses. Copy and paste into the repo. One decimal place, consistent 612×792, no guesswork.
- **PDF Draft** — New flow for fast setup: load a PDF page in the browser, run **Prepare Form** in Acrobat so the PDF has form fields, then **Extract form fields** in our tool. We produce a draft mapping and **open it in the Mapper** with the PDF page as the background. You refine names and positions, then paste the final JSON into the mapping file. Inkscape still owns the final SVG asset; the mapper owns the field positions. Result: most of the mapping is generated from the PDF; the rest is a quick pass in one place.

So we get **carrier-grade layout and alignment** without locking into Adobe or brittle scripts — and we can onboard new forms (and new segments) quickly. For a CTO, that’s maintainable; for sales, that’s a clear operational advantage.

---

## Summary for Partners

- **CID** = Multi-segment commercial insurance distribution (Bar, Roofer, Plumber, HVAC-ready).
- **Platform** = CID App + Famous AI, Netlify forms, segment Node backends on Render, CID_HomeBase (templates + mapper), Supabase, Gmail, SVG-to-PDF engine, COI service.
- **RSS GOLD** = One pattern, one template source, thin backends; ready for CTO review and scale.
- **Mapper** = Browser-based mapping and PDF-draft workflow so we can add and maintain forms fast and keep output print-perfect.

We’re proud of what we’ve built — and we’re ready to show it.

---

*Document: partner-facing overview. Update as you add segments (e.g. HVAC) or new capabilities.*
