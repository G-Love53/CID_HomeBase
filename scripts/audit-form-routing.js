#!/usr/bin/env node
/**
 * Audit Netlify form fields → SUPP / ACORD / routing coverage.
 *
 * Usage (from pdf-backend root):
 *   node CID_HomeBase/scripts/audit-form-routing.js
 *   node CID_HomeBase/scripts/audit-form-routing.js bar
 */
import { auditAllSegments, auditSegmentFormRouting } from "../../src/services/formFieldRoutingService.js";

const segmentArg = process.argv[2];
const results = segmentArg ? [auditSegmentFormRouting(segmentArg)] : auditAllSegments();

console.log("# Form → PDF routing audit\n");
console.log("Legend: meta = analytics only | supp/acord/both = map field | routed = via formFieldRouting | remarks = overflow | client_only = CLIENT_SUBMISSION only (needs mapper)\n");

let totalGaps = 0;
for (const r of results) {
  totalGaps += r.gaps.length;
  console.log(`## ${r.segment.toUpperCase()} — ${r.covered}/${r.total} covered (${r.gaps.length} client-only gaps)`);
  console.log(`  meta: ${r.buckets.meta.length} | supp: ${r.buckets.supp.length} | acord: ${r.buckets.acord.length} | both: ${r.buckets.both.length} | routed: ${r.buckets.routed.length} | remarks: ${r.buckets.remarks.length}`);
  if (r.gaps.length) {
    console.log("  Gaps (add SUPP map or routing rule):");
    for (const g of r.gaps) console.log(`    - ${g}`);
  }
  console.log("");
}

console.log(`Total client-only gaps across segments: ${totalGaps}`);
process.exit(totalGaps > 0 ? 1 : 0);
