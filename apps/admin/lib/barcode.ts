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
