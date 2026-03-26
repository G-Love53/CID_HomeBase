# CID — System Flow

**Purpose:** One-page view of how data and control move through CID. Netlify -> Render -> Gmail -> Carrier -> Bind -> Service App.

---

## High-level

```
LEG 1 (Intake)          LEG 2 (CID-PDF-API pipeline)          LEG 3 (Service)
--------------------   ---------------------------------    ----------------

[Netlify]               [Render: pdf-backend only]         [Famous.ai + Supabase]
  Form                    PDF generation                      Client login
  Submit   ---------->    ACORD + SUPP + CLIENT_SUBMISSION   COI requests
  (segment-specific)      Gmail API send   ---------->      Claims routing
                          Quote inbox                         Policy access
                          S4/S5/S6 operator flow             AI coverage chat
                          Bind/payment   ---------->         Retention
                                    Carrier
```

---

## Step-by-step (LEG 1 -> LEG 2)

1. **Netlify:** Customer fills segment form (Bar, Roofer, Plumber, HVAC). Form posts to `/submit-quote`.
2. **Render (`CID-PDF-API`):** Receives `bundle_id` + form data, records submission, generates PDFs from `CID_HomeBase`, sends outreach.
3. **Gmail:** Outbound packet subject includes bracketed CID token; inbound carrier mail is polled.
4. **Poller ingestion:** `INBOX+UNREAD`, CID token + PDF criteria, auto-label `carrier-quotes`, quote/work-queue creation.
5. **S4/S5:** extraction review then packet builder. Sales letter generation uses Claude with Gemini/template fallback.
6. **S6 Bind:** segment-branded bind-confirmation PDF is sent to BoldSign with fixed placement; webhook/redirect finalization creates policy.
7. **Service App (LEG 3):** Post-bind: client login, COI, claims, policy access, retention. Powered by Famous.ai + Supabase; uses Leg 2 backends as execution engines where needed.

---

## Segment backend role in the flow

- **`pdf-backend` (`CID-PDF-API`)** runs universal Leg 2 pipeline and operator system.
- **Other segment repos** provide segment intake forms/static assets and post to the API host.

