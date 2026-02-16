#!/usr/bin/env node
/**
 * LOCAL-ONLY: Extract AcroForm fields from a PDF → draft cid.map.v1 JSON.
 * This script and its dependency (pdf-lib) live only on your machine for mapping.
 * They are NOT used in Render, Git CI, or Puppeteer; production stays flattened SVG + map JSON.
 *
 * Use: node extract-pdf-fields.js <path-to.pdf> [pageIndex] [--template NAME] [--pageId page-1]
 * Output: stdout (pipe to file or paste into mapper "Apply JSON").
 */

const fs = require("fs");
const path = require("path");
const { PDFDocument } = require("pdf-lib");

const PAGE_W = 612;
const PAGE_H = 792;

function toCanonicalName(pdfName) {
  return String(pdfName)
    .trim()
    .replace(/\s+/g, "_")
    .replace(/[^a-zA-Z0-9_]/g, "")
    .toLowerCase() || "field";
}

function fieldType(f) {
  const c = f.constructor && f.constructor.name;
  if (c === "PDFCheckBox") return "checkbox";
  if (c === "PDFTextField") return "text";
  return "text";
}

async function main() {
  const args = process.argv.slice(2).filter((a) => !a.startsWith("--"));
  const pdfPath = args[0];
  const pageIndex = Math.max(0, parseInt(args[1], 10) || 0);

  const template = process.argv.includes("--template")
    ? process.argv[process.argv.indexOf("--template") + 1] || "SUPP_CONTRACTOR"
    : "SUPP_CONTRACTOR";
  const pageId =
    process.argv.includes("--pageId")
      ? process.argv[process.argv.indexOf("--pageId") + 1] || "page-1"
      : `page-${pageIndex + 1}`;

  if (!pdfPath || !fs.existsSync(pdfPath)) {
    console.error("Usage: node extract-pdf-fields.js <path-to.pdf> [pageIndex] [--template NAME] [--pageId page-1]");
    process.exit(1);
  }

  const buf = fs.readFileSync(pdfPath);
  const doc = await PDFDocument.load(buf);
  const form = doc.getForm();
  const allFields = form.getFields();

  if (allFields.length === 0) {
    console.error("No AcroForm fields found in PDF.");
    const empty = {
      schema: "cid.map.v1",
      units: "base_612x792",
      page: { width: PAGE_W, height: PAGE_H },
      template,
      pageId,
      fields: [],
    };
    console.log(JSON.stringify(empty, null, 2));
    return;
  }

  const fields = [];
  let y = 750;
  for (const f of allFields) {
    const name = toCanonicalName(f.getName());
    const type = fieldType(f);
    const entry = { name, type, x: 72, y };
    if (type === "checkbox") {
      entry.size = 10;
    } else {
      entry.w = 220;
      entry.h = 11;
      entry.fontSize = 8;
    }
    fields.push(entry);
    y -= 18;
  }

  const map = {
    schema: "cid.map.v1",
    units: "base_612x792",
    page: { width: PAGE_W, height: PAGE_H },
    template,
    pageId,
    fields,
  };

  console.log(JSON.stringify(map, null, 2));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
