/**
 * Barcode Utilities
 *
 * Utilities for generating and managing product barcodes.
 * Supports automatic barcode generation and manual barcode input.
 *
 * @module lib/barcode
 */

/**
 * Generate a random barcode number
 */
export function generateBarcodeNumber(): string {
  const timestamp = Date.now().toString();
  const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
  return `PRD${timestamp.slice(-6)}${random}`;
}

/**
 * Validate barcode format
 */
export function validateBarcode(barcode: string): boolean {
  // Basic validation - alphanumeric, 8-20 characters
  return /^[A-Z0-9]{8,20}$/.test(barcode);
}

/**
 * Generate barcode SVG as data URL
 */
export async function generateBarcodeSVG(barcode: string, options?: {
  width?: number;
  height?: number;
  format?: string;
}): Promise<string> {
  const JsBarcode = (await import('jsbarcode')).default;
  const canvas = document.createElement('canvas');
  JsBarcode(canvas, barcode, {
    width: options?.width || 2,
    height: options?.height || 100,
    format: options?.format || 'CODE128',
    displayValue: true,
    fontSize: 14,
    margin: 10,
  });
  
  return canvas.toDataURL();
}

/**
 * Generate barcode and download as PNG
 */
export async function downloadBarcode(
  barcode: string, 
  productName: string,
  options?: { width?: number; height?: number; }
): Promise<void> {
  try {
    const JsBarcode = (await import('jsbarcode')).default;
    const barcodeCanvas = document.createElement('canvas');
    JsBarcode(barcodeCanvas, barcode, {
      width: options?.width || 2,
      height: options?.height || 100,
      format: 'CODE128',
      displayValue: true,
      fontSize: 14,
      margin: 10,
    });
    
    const finalCanvas = document.createElement('canvas');
    const ctx = finalCanvas.getContext('2d');
    if (!ctx) throw new Error('Could not get canvas context');
    
    const padding = 20;
    const textSpace = 30;
    
    finalCanvas.width = barcodeCanvas.width + (padding * 2);
    finalCanvas.height = barcodeCanvas.height + textSpace + (padding * 2);
    
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, finalCanvas.width, finalCanvas.height);
    ctx.drawImage(barcodeCanvas, padding, padding);
    
    ctx.fillStyle = '#000000';
    ctx.font = 'bold 14px Arial, sans-serif';
    ctx.textAlign = 'center';
    
    let displayName = productName;
    if (displayName.length > 40) {
      displayName = displayName.substring(0, 37) + '...';
    }
    
    ctx.fillText(displayName, finalCanvas.width / 2, finalCanvas.height - padding);
    
    const link = document.createElement('a');
    link.download = `barcode-${barcode}-${productName.replace(/[^a-zA-Z0-9]/g, '_')}.png`;
    link.href = finalCanvas.toDataURL('image/png');
    link.click();
  } catch (error) {
    console.error('Error generating barcode:', error);
    throw new Error('Failed to generate barcode');
  }
}

/**
 * Generate barcode and open print dialog
 */
export async function printBarcode(
  barcode: string, 
  productName: string,
  options?: { width?: number; height?: number; }
): Promise<void> {
  try {
    const JsBarcode = (await import('jsbarcode')).default;
    const barcodeCanvas = document.createElement('canvas');
    JsBarcode(barcodeCanvas, barcode, {
      width: options?.width || 3,
      height: options?.height || 120,
      format: 'CODE128',
      displayValue: true,
      fontSize: 14,
      margin: 10,
    });
    
    const finalCanvas = document.createElement('canvas');
    const ctx = finalCanvas.getContext('2d');
    if (!ctx) throw new Error('Could not get canvas context');
    
    const padding = 20;
    const textSpace = 30;
    
    finalCanvas.width = barcodeCanvas.width + (padding * 2);
    finalCanvas.height = barcodeCanvas.height + textSpace + (padding * 2);
    
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, finalCanvas.width, finalCanvas.height);
    ctx.drawImage(barcodeCanvas, padding, padding);
    
    ctx.fillStyle = '#000000';
    ctx.font = 'bold 14px Arial, sans-serif';
    ctx.textAlign = 'center';
    
    let displayName = productName;
    if (displayName.length > 40) {
      displayName = displayName.substring(0, 37) + '...';
    }
    
    ctx.fillText(displayName, finalCanvas.width / 2, finalCanvas.height - padding);
    
    const dataUrl = finalCanvas.toDataURL('image/png');
    
    // Create an iframe to print the image
    const iframe = document.createElement('iframe');
    iframe.style.position = 'fixed';
    iframe.style.right = '0';
    iframe.style.bottom = '0';
    iframe.style.width = '0';
    iframe.style.height = '0';
    iframe.style.border = '0';
    document.body.appendChild(iframe);
    
    const iframeDoc = iframe.contentWindow?.document || iframe.contentDocument;
    if (!iframeDoc) throw new Error('Could not get iframe document');
    
    iframeDoc.write(`
      <html>
        <head>
          <title>Print Barcode - ${barcode}</title>
          <style>
            @page {
              margin: 0;
              size: auto;
            }
            body {
              margin: 0;
              padding: 0;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              background-color: white;
            }
            img {
              width: 100%;
              max-width: 600px; /* optimal size for standard print sheets, scales down for small labels */
              height: auto;
              display: block;
              image-rendering: -webkit-optimize-contrast;
              image-rendering: crisp-edges;
            }
          </style>
        </head>
        <body>
          <img src="${dataUrl}" />
          <script>
            window.onload = function() {
              window.focus();
              window.print();
              setTimeout(function() {
                window.parent.document.body.removeChild(window.frameElement);
              }, 1000);
            };
          </script>
        </body>
      </html>
    `);
    iframeDoc.close();
  } catch (error) {
    console.error('Error printing barcode:', error);
    throw new Error('Failed to print barcode');
  }
}


/**
 * Generate multiple barcodes for bulk download
 */
export async function downloadMultipleBarcodes(
  products: Array<{ barcode: string; name: string }>,
  options?: { width?: number; height?: number; }
): Promise<void> {
  try {
    for (const product of products) {
      await downloadBarcode(product.barcode, product.name, options);
    }
  } catch (error) {
    console.error('Error generating bulk barcodes:', error);
    throw new Error('Failed to generate bulk barcodes');
  }
}

/**
 * Check if barcode is unique (placeholder for API call)
 */
export async function checkBarcodeUniqueness(barcode: string, excludeId?: string): Promise<boolean> {
  // This would typically make an API call to check uniqueness
  // For now, return true (assume unique)
  return true;
}

/**
 * Label size presets for bulk barcode printing on A4 sheets.
 * All dimensions in millimeters. A4 = 210mm × 297mm.
 */
export type LabelSizeKey = 'price-tag' | 'small-square' | 'large-label';

export interface LabelSize {
  key: LabelSizeKey;
  label: string;
  description: string;
  width_mm: number;
  height_mm: number;
  cols: number;
  rows: number;
  gap_mm: number;
  margin_mm: number;
  perSheet: number;
}

export const LABEL_SIZES: Record<LabelSizeKey, LabelSize> = {
  'price-tag': {
    key: 'price-tag',
    label: '35mm × 16mm',
    description: 'Price tag — 80 labels per sheet',
    width_mm: 35,
    height_mm: 16,
    cols: 5,
    rows: 16,
    gap_mm: 3,
    margin_mm: 7,
    perSheet: 80,
  },
  'small-square': {
    key: 'small-square',
    label: '25mm × 25mm',
    description: 'Small square — 77 labels per sheet',
    width_mm: 25,
    height_mm: 25,
    cols: 7,
    rows: 11,
    gap_mm: 2,
    margin_mm: 5,
    perSheet: 77,
  },
  'large-label': {
    key: 'large-label',
    label: '50mm × 25mm',
    description: 'Best for costume labels — 30 per sheet',
    width_mm: 50,
    height_mm: 25,
    cols: 3,
    rows: 10,
    gap_mm: 5,
    margin_mm: 10,
    perSheet: 30,
  },
};

/**
 * Render a single barcode label as a high-DPI PNG data URL.
 * Uses 3× supersampling for crisp print output (~288 DPI equivalent).
 */
async function renderBarcodeLabel(
  barcode: string,
  productName: string,
  barWidth: number,
  barHeight: number,
  fontSize: number,
): Promise<string> {
  const JsBarcode = (await import('jsbarcode')).default;
  const scale = 3;

  const barcodeCanvas = document.createElement('canvas');
  JsBarcode(barcodeCanvas, barcode, {
    width: barWidth * scale,
    height: barHeight * scale,
    format: 'CODE128',
    displayValue: true,
    fontSize: fontSize * scale,
    margin: 2 * scale,
    textMargin: 2 * scale,
  });

  const padding = 4 * scale;
  const textSpace = (fontSize + 4) * scale;
  const finalCanvas = document.createElement('canvas');
  const ctx = finalCanvas.getContext('2d');
  if (!ctx) throw new Error('Could not get canvas context');

  finalCanvas.width = barcodeCanvas.width + padding * 2;
  finalCanvas.height = barcodeCanvas.height + textSpace + padding * 2;

  ctx.fillStyle = '#ffffff';
  ctx.fillRect(0, 0, finalCanvas.width, finalCanvas.height);
  ctx.drawImage(barcodeCanvas, padding, padding);

  ctx.fillStyle = '#000000';
  ctx.font = `bold ${fontSize * scale}px Arial, sans-serif`;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'bottom';

  let displayName = productName;
  const maxChars = Math.floor(finalCanvas.width / (fontSize * scale * 0.55));
  if (displayName.length > maxChars) {
    displayName = displayName.substring(0, maxChars - 1) + '…';
  }

  ctx.fillText(displayName, finalCanvas.width / 2, finalCanvas.height - padding);

  return finalCanvas.toDataURL('image/png');
}

/**
 * Bulk print barcodes on A4 label sheets with a single print dialog.
 *
 * Renders all barcodes at 3× DPI for print clarity, lays them out in a
 * CSS grid matching the selected label size, and opens one print dialog.
 *
 * @param products - Array of { barcode, name } to print
 * @param sizeKey - Label size key ('price-tag' | 'small-square' | 'large-label')
 */
export async function bulkPrintBarcodes(
  products: Array<{ barcode: string; name: string }>,
  sizeKey: LabelSizeKey = 'price-tag',
): Promise<void> {
  if (products.length === 0) return;

  const size = LABEL_SIZES[sizeKey];
  const perSheet = size.perSheet;

  const renderParams: Record<LabelSizeKey, { barWidth: number; barHeight: number; fontSize: number }> = {
    'price-tag': { barWidth: 1, barHeight: 28, fontSize: 7 },
    'small-square': { barWidth: 1, barHeight: 38, fontSize: 7 },
    'large-label': { barWidth: 2, barHeight: 48, fontSize: 9 },
  };
  const rp = renderParams[sizeKey];

  const dataUrls: string[] = [];
  for (const product of products) {
    try {
      const url = await renderBarcodeLabel(product.barcode, product.name, rp.barWidth, rp.barHeight, rp.fontSize);
      dataUrls.push(url);
    } catch (err) {
      console.error(`Failed to generate barcode for ${product.barcode}:`, err);
    }
  }

  if (dataUrls.length === 0) {
    throw new Error('No barcodes could be generated');
  }

  const sheets: string[] = [];
  for (let i = 0; i < dataUrls.length; i += perSheet) {
    const chunk = dataUrls.slice(i, i + perSheet);
    const cells = chunk
      .map((url) => `<div class="label"><img src="${url}" alt="barcode" /></div>`)
      .join('');
    sheets.push(`<div class="sheet">${cells}</div>`);
  }

  const html = `<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Bulk Barcode Print — ${dataUrls.length} labels (${size.label})</title>
<style>
  @page {
    size: A4;
    margin: 0;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    padding: 0;
    background: #e0e0e0;
    font-family: Arial, sans-serif;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }
  .sheet {
    width: 210mm;
    height: 297mm;
    padding: ${size.margin_mm}mm;
    display: grid;
    grid-template-columns: repeat(${size.cols}, 1fr);
    grid-template-rows: repeat(${size.rows}, 1fr);
    gap: ${size.gap_mm}mm;
    background: white;
    page-break-after: always;
    break-after: page;
  }
  .sheet:last-child {
    page-break-after: auto;
    break-after: auto;
  }
  .label {
    width: ${size.width_mm}mm;
    height: ${size.height_mm}mm;
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .label img {
    max-width: 100%;
    max-height: 100%;
    width: auto;
    height: auto;
    object-fit: contain;
    image-rendering: -webkit-optimize-contrast;
    image-rendering: crisp-edges;
  }
  @media print {
    body { background: white; }
  }
</style>
</head>
<body>
${sheets.join('')}
<script>
  window.onload = function() {
    window.focus();
    window.print();
    setTimeout(function() {
      var f = window.frameElement;
      if (f) f.parentNode.removeChild(f);
    }, 1000);
  };
</script>
</body>
</html>`;

  const iframe = document.createElement('iframe');
  iframe.style.position = 'fixed';
  iframe.style.right = '0';
  iframe.style.bottom = '0';
  iframe.style.width = '0';
  iframe.style.height = '0';
  iframe.style.border = '0';
  document.body.appendChild(iframe);

  const iframeDoc = iframe.contentWindow?.document || iframe.contentDocument;
  if (!iframeDoc) throw new Error('Could not get iframe document');

  iframeDoc.open();
  iframeDoc.write(html);
  iframeDoc.close();
}
