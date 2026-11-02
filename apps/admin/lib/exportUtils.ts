/**
 * Export Utilities
 *
 * Client-side helpers for exporting report data to Excel (.xlsx) and PDF.
 * Uses jspdf + jspdf-autotable for PDF generation.
 * Uses SheetJS for Excel workbooks with explicit date formats and column widths.
 *
 * @module lib/exportUtils
 */

interface ExportColumn {
  header: string;
  key: string;
  format?: 'currency' | 'number' | 'date' | 'percent';
  width?: number;
}

/**
 * Export a workbook with readable dates and numeric amounts.
 *
 * @param data Complete report rows to export.
 * @param columns Ordered report columns and their display formats.
 * @param filename Download name without an extension.
 * @returns Resolves after the workbook download starts.
 */
export async function exportToExcel(
  data: Record<string, any>[],
  columns: ExportColumn[],
  filename: string
) {
  const XLSX = await import('xlsx');
  const headers = columns.map(c => c.header);
  const rows = data.map(row =>
    columns.map(col => {
      const val = row[col.key];
      if (val == null || val === '') return '';
      if (col.format === 'date') {
        // Date-only values are calendar dates, not UTC instants: preserve the
        // same day when the workbook is generated outside India's timezone.
        const date = new Date(typeof val === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(val)
          ? `${val}T00:00:00`
          : val);
        if (Number.isFinite(date.getTime()) && date.getFullYear() >= 1900 && date.getFullYear() <= 9999) {
          return date;
        }
        return String(val);
      }
      if (col.format === 'currency' || col.format === 'number' || col.format === 'percent') {
        const number = Number(val);
        if (Number.isFinite(number)) return col.format === 'percent' ? number / 100 : number;
      }
      return String(val);
    })
  );

  const sheet = XLSX.utils.aoa_to_sheet([headers, ...rows], { dateNF: 'dd/mm/yyyy' });
  sheet['!cols'] = columns.map((col, columnIndex) => {
    let width = Math.max(col.format === 'date' ? 16 : 12, col.header.length + 3);
    for (let rowIndex = 1; rowIndex <= rows.length; rowIndex++) {
      const cell = sheet[XLSX.utils.encode_cell({ r: rowIndex, c: columnIndex })];
      if (!cell) continue;
      if (cell.t === 'n') {
        if (col.format === 'currency') cell.z = '#,##0.00';
        if (col.format === 'percent') cell.z = '0.0%';
      }
      width = Math.max(width, XLSX.utils.format_cell(cell).length + 3);
    }
    // CSV cannot retain widths, which leaves Excel dates showing as #######.
    return { wch: Math.min(width, 60) };
  });

  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, sheet, 'Report');
  const bytes = XLSX.write(workbook, { bookType: 'xlsx', type: 'array', compression: true });
  const blob = new Blob([bytes], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
  downloadBlob(blob, `${filename}.xlsx`);
}

/**
 * Export data to PDF
 */
export async function exportToPDF(
  data: Record<string, any>[],
  columns: ExportColumn[],
  title: string,
  filename: string
) {
  const jsPDF = (await import('jspdf')).default;
  const autoTable = (await import('jspdf-autotable')).default;

  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

  // Title
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.text(title, 14, 18);

  // Subtitle
  doc.setFontSize(9);
  doc.setFont('helvetica', 'normal');
  doc.setTextColor(120, 120, 120);
  doc.text(`Generated: ${new Date().toLocaleDateString('en-IN', { day: 'numeric', month: 'long', year: 'numeric' })}`, 14, 24);
  doc.text(`Mazhavil Dance Costumes`, 14, 29);
  doc.setTextColor(0, 0, 0);

  // Table
  const head = [columns.map(c => c.header)];
  const body = data.map(row =>
    columns.map(col => {
      const val = row[col.key];
      if (val == null) return '';
      if (col.format === 'currency') return `Rs. ${Number(val).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
      if (col.format === 'percent') return `${Number(val).toFixed(1)}%`;
      if (col.format === 'date' && val) {
        try { 
          const d = new Date(val);
          return d.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' }).replace(/ /g, '-');
        } catch { return val; }
      }
      return String(val);
    })
  );

  autoTable(doc, {
    head,
    body,
    startY: 34,
    theme: 'grid',
    styles: { fontSize: 8, cellPadding: 3, lineColor: [220, 220, 220], lineWidth: 0.1 },
    headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold', fontSize: 8 },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    margin: { left: 14, right: 14 },
  });

  doc.save(`${filename}.pdf`);
}

function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

// ─────────────────────────────────────────────────────────────
// GST Filing exports
//
// The generic exporters above dump a single table, which is not
// enough to file a return from: GSTR filing needs the rate-wise
// summary (the figures actually entered in the portal), the
// CGST/SGST split, grand totals, and the business GSTIN + period
// on the document. These two exporters produce filing-grade files.
// ─────────────────────────────────────────────────────────────

export interface GstFilingExportPayload {
  businessName: string;
  gstin: string;
  period: string;
  summary: Array<{ slab: number; taxable_value: number; cgst: number; sgst: number; total_gst: number }>;
  totals: { taxable: number; cgst: number; sgst: number; gst: number };
  composition?: { total_orders: number; gst_orders: number; non_gst_orders: number };
  excluded?: Record<string, { orders: number; taxable_value: number; gst_amount: number }>;
  /** Full invoice register — NOT the on-screen filtered subset (a filing document must be complete). */
  invoices: Array<Record<string, any>>;
}

const GST_INVOICE_COLUMNS = [
  { header: "Invoice No", key: "invoice_no" },
  { header: "Date", key: "date" },
  { header: "Customer", key: "customer_name" },
  { header: "Status", key: "status" },
  { header: "GST Rate(s)", key: "slabs" },
  { header: "Total Invoice Value", key: "total_value", format: "currency" as const },
  { header: "Taxable Value", key: "taxable_value", format: "currency" as const },
  { header: "Exempt Value", key: "exempt_value", format: "currency" as const },
  { header: "CGST", key: "cgst", format: "currency" as const },
  { header: "SGST", key: "sgst", format: "currency" as const },
  { header: "Total GST", key: "gst_amount", format: "currency" as const },
];

function gstInvoiceRow(row: Record<string, any>) {
  return GST_INVOICE_COLUMNS.map(col => {
    const val = row[col.key];
    if (col.key === "status") return String(val || "").replace(/_/g, ' ');
    if (col.key === "date" && val) return String(val).slice(0, 10);
    if (col.key === "slabs") return val || '-';
    if (val == null) return '';
    if (col.format === 'currency') return Number(val);
    return String(val);
  });
}

function gstInvoiceType(row: Record<string, any>) {
  if (row.has_gst && row.has_exempt) return "Mixed";
  return row.has_gst ? "GST" : "Exempt";
}

function gstFooterNoteLines(payload: GstFilingExportPayload): string[] {
  const lines: string[] = [];
  if (payload.composition) {
    lines.push(
      `Orders in scope: ${payload.composition.total_orders} with line items — ` +
      `${payload.composition.gst_orders} carrying GST, ${payload.composition.non_gst_orders} fully exempt.`
    );
  }
  const excluded = Object.entries(payload.excluded || {})
    .filter(([, v]) => v.orders > 0)
    .map(([status, v]) => `${v.orders} ${status.replace(/_/g, ' ')} (taxable Rs. ${v.taxable_value.toLocaleString('en-IN')}, GST Rs. ${v.gst_amount.toLocaleString('en-IN')})`);
  if (excluded.length) {
    lines.push(`Excluded from this period (not finalized / cancelled): ${excluded.join('; ')}.`);
  }
  lines.push('Filing basis: invoices dated in the period for rentals that concluded (completed or fully returned).');
  return lines;
}

/**
 * Export the GST filing report as a real .xlsx workbook:
 * Sheet 1 "Filing Summary" (rate-wise taxable/CGST/SGST + totals + scope notes),
 * Sheet 2 "Invoice Register" (full invoice list with CGST/SGST + totals row).
 */
export async function exportGstFilingToExcel(payload: GstFilingExportPayload, filename: string) {
  const XLSX = await import('xlsx');

  const summaryAoA: any[][] = [
    [payload.businessName],
    [`GSTIN: ${payload.gstin}`],
    [`Period: ${payload.period}`],
    [`Generated: ${new Date().toLocaleDateString('en-IN', { day: 'numeric', month: 'long', year: 'numeric' })}`],
    [],
    ['GST Rate', 'Taxable Value (Rs.)', 'CGST (Rs.)', 'SGST (Rs.)', 'Total GST (Rs.)'],
    ...payload.summary.map(s => [`${s.slab}%`, s.taxable_value, s.cgst, s.sgst, s.total_gst]),
    ['TOTAL', payload.totals.taxable, payload.totals.cgst, payload.totals.sgst, payload.totals.gst],
    [],
    ...gstFooterNoteLines(payload).map(l => [l]),
  ];
  const summarySheet = XLSX.utils.aoa_to_sheet(summaryAoA);
  summarySheet['!cols'] = [{ wch: 18 }, { wch: 20 }, { wch: 14 }, { wch: 14 }, { wch: 16 }];

  const invoiceAoA: any[][] = [
    [...GST_INVOICE_COLUMNS.map(c => c.header), 'Type'],
    ...payload.invoices.map(r => [...gstInvoiceRow(r), gstInvoiceType(r)]),
    [
      'TOTAL', '', '', '', '',
      payload.invoices.reduce((s, r) => s + Number(r.total_value || 0), 0),
      // Tax figures tie to the SUMMARY totals — the column sum of per-invoice
      // rounded values can drift by a few paise from the filing figures.
      payload.totals.taxable,
      payload.invoices.reduce((s, r) => s + Number(r.exempt_value || 0), 0),
      payload.totals.cgst,
      payload.totals.sgst,
      payload.totals.gst,
      '',
    ],
  ];
  const invoiceSheet = XLSX.utils.aoa_to_sheet(invoiceAoA);
  invoiceSheet['!cols'] = [
    { wch: 18 }, { wch: 12 }, { wch: 26 }, { wch: 12 }, { wch: 12 },
    { wch: 18 }, { wch: 16 }, { wch: 14 }, { wch: 12 }, { wch: 12 }, { wch: 14 }, { wch: 9 },
  ];

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, summarySheet, 'Filing Summary');
  XLSX.utils.book_append_sheet(wb, invoiceSheet, 'Invoice Register');
  XLSX.writeFile(wb, `${filename}.xlsx`);
}

/**
 * Export the GST filing report as a filing-grade PDF: business header with
 * GSTIN + period, rate-wise summary table with totals, then the full invoice
 * register (CGST/SGST split) with a totals row on every continuing table.
 */
export async function exportGstFilingToPDF(payload: GstFilingExportPayload, filename: string) {
  const jsPDF = (await import('jspdf')).default;
  const autoTable = (await import('jspdf-autotable')).default;

  const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });
  const fmt = (v: any) => `Rs. ${Number(v || 0).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

  doc.setFontSize(15);
  doc.setFont('helvetica', 'bold');
  doc.text(payload.businessName, 14, 15);
  doc.setFontSize(9);
  doc.setFont('helvetica', 'normal');
  doc.text(`GSTIN: ${payload.gstin}   |   Period: ${payload.period}`, 14, 21);
  doc.setTextColor(120, 120, 120);
  doc.text(`Generated: ${new Date().toLocaleDateString('en-IN', { day: 'numeric', month: 'long', year: 'numeric' })}`, 14, 26);
  doc.setTextColor(0, 0, 0);

  autoTable(doc, {
    head: [['GST Rate', 'Taxable Value', 'CGST', 'SGST', 'Total GST']],
    body: payload.summary.map(s => [`${s.slab}%`, fmt(s.taxable_value), fmt(s.cgst), fmt(s.sgst), fmt(s.total_gst)]),
    foot: [['TOTAL', fmt(payload.totals.taxable), fmt(payload.totals.cgst), fmt(payload.totals.sgst), fmt(payload.totals.gst)]],
    startY: 31,
    theme: 'grid',
    styles: { fontSize: 9, cellPadding: 3, lineColor: [220, 220, 220], lineWidth: 0.1 },
    headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold' },
    footStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42], fontStyle: 'bold' },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    margin: { left: 14, right: 14 },
  });

  // Scope notes under the summary table
  let noteY = (doc as any).lastAutoTable.finalY + 6;
  doc.setFontSize(8);
  doc.setTextColor(90, 90, 90);
  gstFooterNoteLines(payload).forEach(line => {
    const wrapped = doc.splitTextToSize(line, doc.internal.pageSize.getWidth() - 28);
    doc.text(wrapped, 14, noteY);
    noteY += wrapped.length * 4;
  });
  doc.setTextColor(0, 0, 0);

  doc.setFontSize(11);
  doc.setFont('helvetica', 'bold');
  doc.text('Invoice Register', 14, noteY + 4);

  autoTable(doc, {
    head: [[...GST_INVOICE_COLUMNS.map(c => c.header), 'Type']],
    body: payload.invoices.map(row => {
      const cells = gstInvoiceRow(row);
      return cells.map((c, i) => (GST_INVOICE_COLUMNS[i]?.format === 'currency' ? fmt(c) : c)).concat(gstInvoiceType(row));
    }),
    foot: [[
      'TOTAL', '', '', '', '',
      fmt(payload.invoices.reduce((s, r) => s + Number(r.total_value || 0), 0)),
      fmt(payload.totals.taxable),
      fmt(payload.invoices.reduce((s, r) => s + Number(r.exempt_value || 0), 0)),
      fmt(payload.totals.cgst),
      fmt(payload.totals.sgst),
      fmt(payload.totals.gst),
      '',
    ]],
    startY: noteY + 8,
    theme: 'grid',
    styles: { fontSize: 7.5, cellPadding: 2, lineColor: [220, 220, 220], lineWidth: 0.1, overflow: 'linebreak' },
    headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold', fontSize: 7.5 },
    footStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42], fontStyle: 'bold', fontSize: 7.5 },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    columnStyles: {
      1: { cellWidth: 18 },  // Date
      5: { halign: 'right' }, 6: { halign: 'right' }, 7: { halign: 'right' },
      8: { halign: 'right' }, 9: { halign: 'right' }, 10: { halign: 'right' },
    },
    margin: { left: 14, right: 14, top: 14 },
    didDrawPage: () => {
      const page = doc.getNumberOfPages();
      doc.setFontSize(8);
      doc.setTextColor(120, 120, 120);
      doc.text(
        `${payload.businessName} — GST Filing — ${payload.period} — Page ${page}`,
        doc.internal.pageSize.getWidth() - 14,
        doc.internal.pageSize.getHeight() - 6,
        { align: 'right' }
      );
      doc.setTextColor(0, 0, 0);
    },
  });

  doc.save(`${filename}.pdf`);
}
