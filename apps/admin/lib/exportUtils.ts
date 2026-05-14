/**
 * Export Utilities
 *
 * Client-side helpers for exporting report data to Excel (.xlsx) and PDF.
 * Uses jspdf + jspdf-autotable for PDF generation.
 * Uses a lightweight CSV-based approach for Excel (no extra dependency).
 *
 * @module lib/exportUtils
 */

import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

interface ExportColumn {
  header: string;
  key: string;
  format?: 'currency' | 'number' | 'date' | 'percent';
  width?: number;
}

/**
 * Export data to CSV (opens as Excel)
 */
export function exportToExcel(
  data: Record<string, any>[],
  columns: ExportColumn[],
  filename: string
) {
  const headers = columns.map(c => c.header);
  const rows = data.map(row =>
    columns.map(col => {
      const val = row[col.key];
      if (val == null) return '';
      if (col.format === 'currency') return Number(val).toFixed(2);
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

  const csvContent = [
    headers.join(','),
    ...rows.map(r => r.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(','))
  ].join('\n');

  const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
  downloadBlob(blob, `${filename}.csv`);
}

/**
 * Export data to PDF
 */
export function exportToPDF(
  data: Record<string, any>[],
  columns: ExportColumn[],
  title: string,
  filename: string
) {
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
      if (col.format === 'currency') return `₹${Number(val).toLocaleString('en-IN', { minimumFractionDigits: 2 })}`;
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
