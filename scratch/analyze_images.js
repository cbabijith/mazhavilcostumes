const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Configuration
let supabaseUrl;
let supabaseServiceKey;

try {
  const envContent = fs.readFileSync('apps/admin/.env.local', 'utf8');
  const lines = envContent.split('\n');
  for (const line of lines) {
    if (line.startsWith('NEXT_PUBLIC_SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].trim();
    }
    if (line.startsWith('SUPABASE_SERVICE_ROLE_KEY=')) {
      supabaseServiceKey = line.split('=')[1].trim();
    }
  }
} catch (e) {
  console.error("Failed to read apps/admin/.env.local", e);
  process.exit(1);
}

if (!supabaseUrl || !supabaseServiceKey) {
  console.error("Missing Supabase configuration in apps/admin/.env.local");
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Recursive directory scanning
function getFilesRecursively(dir, fileList = []) {
  try {
    const files = fs.readdirSync(dir);
    for (const file of files) {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);
      if (stat.isDirectory()) {
        getFilesRecursively(fullPath, fileList);
      } else {
        const ext = path.extname(file).toLowerCase();
        if (['.jpg', '.jpeg', '.png', '.webp'].includes(ext)) {
          fileList.push({
            name: file,
            baseName: path.basename(file, ext),
            ext: ext,
            fullPath: fullPath,
            size: stat.size
          });
        }
      }
    }
  } catch (err) {
    console.error(`Error reading directory ${dir}:`, err.message);
  }
  return fileList;
}

async function fetchAllProducts() {
  const allProducts = [];
  let page = 0;
  const pageSize = 1000;
  let hasMore = true;

  while (hasMore) {
    const from = page * pageSize;
    const to = from + pageSize - 1;

    const { data, error } = await supabase
      .from('products')
      .select('id, name, barcode, sku, category_id, images')
      .is('deleted_at', null)
      .range(from, to);

    if (error) {
      throw error;
    }

    if (!data || data.length === 0) {
      hasMore = false;
    } else {
      allProducts.push(...data);
      if (data.length < pageSize) {
        hasMore = false;
      } else {
        page++;
      }
    }
  }

  return allProducts;
}

async function main() {
  console.log("=== STEP 1: SCANNING LOCAL IMAGES ===");
  const localImagesDir = "D:\\personal\\mazhavil images";
  console.log(`Scanning local images at: ${localImagesDir}`);
  const localFiles = getFilesRecursively(localImagesDir);
  console.log(`Found ${localFiles.length} image files locally.`);

  // Create a map of normalized filename (baseName) -> file info
  const localFilesMap = new Map();
  for (const f of localFiles) {
    const key = f.baseName.trim().toLowerCase();
    if (!localFilesMap.has(key)) {
      localFilesMap.set(key, []);
    }
    localFilesMap.get(key).push(f);
  }
  console.log(`Unique local image codes found: ${localFilesMap.size}`);

  console.log("\n=== STEP 2: FETCHING PRODUCTS AND CATEGORIES ===");
  // Fetch all categories for reference
  const { data: categories, error: catError } = await supabase
    .from('categories')
    .select('id, name, slug');

  if (catError) {
    console.error("Error fetching categories:", catError);
    process.exit(1);
  }

  const categoryMap = new Map();
  categories.forEach(c => categoryMap.set(c.id, c));
  console.log(`Fetched ${categories.length} categories.`);

  // Fetch all products with pagination
  const products = await fetchAllProducts();
  console.log(`Fetched total of ${products.length} products.`);

  console.log("\n=== STEP 3: ANALYZING MATCHES ===");

  const matched = [];
  const unmatchedLocal = [];
  const missingImages = [];
  const alreadyHasDbImage = [];

  // Track match status by category
  // catId -> { name, total, matched, missing, hasDbImage }
  const categoryStats = new Map();
  categories.forEach(c => {
    categoryStats.set(c.id, { name: c.name, total: 0, matched: 0, missing: 0, hasDbImage: 0 });
  });
  // Add an entry for "Uncategorized"
  categoryStats.set('null', { name: 'Uncategorized', total: 0, matched: 0, missing: 0, hasDbImage: 0 });

  for (const product of products) {
    const catId = product.category_id || 'null';
    const stats = categoryStats.get(catId);
    if (!stats) continue;
    stats.total++;

    // Check if product already has image in DB
    const hasImage = Array.isArray(product.images) && product.images.length > 0;
    if (hasImage) {
      stats.hasDbImage++;
      alreadyHasDbImage.push({
        product,
        images: product.images,
        categoryName: stats.name
      });
      continue;
    }

    // Try to match by barcode or name or sku
    const normalizedBarcode = product.barcode ? product.barcode.trim().toLowerCase() : null;
    const normalizedName = product.name ? product.name.trim().toLowerCase() : null;
    const normalizedSku = product.sku ? product.sku.trim().toLowerCase() : null;

    let matchedFiles = null;
    if (normalizedBarcode && localFilesMap.has(normalizedBarcode)) {
      matchedFiles = localFilesMap.get(normalizedBarcode);
    } else if (normalizedName && localFilesMap.has(normalizedName)) {
      matchedFiles = localFilesMap.get(normalizedName);
    } else if (normalizedSku && localFilesMap.has(normalizedSku)) {
      matchedFiles = localFilesMap.get(normalizedSku);
    }

    if (matchedFiles) {
      stats.matched++;
      matched.push({
        product,
        files: matchedFiles,
        categoryName: stats.name
      });
      // Mark these local files as matched
      matchedFiles.forEach(f => f.used = true);
    } else {
      stats.missing++;
      missingImages.push({
        product,
        categoryName: stats.name
      });
    }
  }

  // Find unmatched local files
  for (const f of localFiles) {
    if (!f.used) {
      unmatchedLocal.push(f);
    }
  }

  console.log("\n=== STEP 4: GENERATING REPORT ===");
  
  // Build Markdown Report
  let report = `# Product Image Analysis Report\n\n`;
  report += `Generated at: ${new Date().toLocaleString()}\n\n`;
  
  report += `## Summary Statistics\n\n`;
  report += `| Metric | Count | Description |\n`;
  report += `| :--- | :--- | :--- |\n`;
  report += `| **Total Products in Database** | ${products.length} | Total products registered in Supabase |\n`;
  report += `| **Products with Database Images** | ${alreadyHasDbImage.length} | Already have image URLs (e.g. manually added) |\n`;
  report += `| **Products Matched with Local Files** | ${matched.length} | Ready to be uploaded |\n`;
  report += `| **Products Missing Images** | ${missingImages.length} | No local match and no database image |\n`;
  report += `| **Unmatched Local Image Files** | ${unmatchedLocal.length} | Image files that don't match any product code |\n`;
  report += `| **Total Local Image Files Found** | ${localFiles.length} | In D:\\personal\\mazhavil images |\n\n`;

  report += `## Category Breakdown\n\n`;
  report += `| Category | Total Products | Has Image in DB | Matched (Ready to Upload) | Missing Image |\n`;
  report += `| :--- | :---: | :---: | :---: | :---: |\n`;
  
  // Sort stats by category name
  const sortedStats = Array.from(categoryStats.values()).sort((a, b) => a.name.localeCompare(b.name));
  for (const stat of sortedStats) {
    if (stat.total === 0) continue; // Skip empty categories
    report += `| **${stat.name}** | ${stat.total} | ${stat.hasDbImage} | ${stat.matched} | ${stat.missing} |\n`;
  }
  
  report += `\n## Sample of Products with Images already in DB (Manually Added)\n\n`;
  if (alreadyHasDbImage.length === 0) {
    report += `None found.\n`;
  } else {
    report += `Showing up to 20 products:\n\n`;
    report += `| Product Code/Name | SKU/Description | Category | Images in DB |\n`;
    report += `| :--- | :--- | :--- | :--- |\n`;
    alreadyHasDbImage.slice(0, 20).forEach(item => {
      report += `| \`${item.product.name}\` | ${item.product.sku || '-'} | ${item.categoryName} | \`${JSON.stringify(item.images)}\` |\n`;
    });
  }

  report += `\n## Sample of Products Missing Local Matches\n\n`;
  if (missingImages.length === 0) {
    report += `None! All products have either a DB image or a matching local file.\n`;
  } else {
    report += `Showing up to 30 products:\n\n`;
    report += `| Product Code/Name | SKU/Description | Category |\n`;
    report += `| :--- | :--- | :--- |\n`;
    missingImages.slice(0, 30).forEach(item => {
      report += `| \`${item.product.name}\` | ${item.product.sku || '-'} | ${item.categoryName} |\n`;
    });
    if (missingImages.length > 30) {
      report += `\n*...and ${missingImages.length - 30} more missing products.*\n`;
    }
  }

  report += `\n## Sample of Unmatched Local Image Files\n\n`;
  if (unmatchedLocal.length === 0) {
    report += `None! All local files matched a product.\n`;
  } else {
    report += `Showing up to 30 files:\n\n`;
    report += `| File Name | Directory Folder | File Size |\n`;
    report += `| :--- | :--- | :--- |\n`;
    
    // Sort unmatched files by folder/name
    unmatchedLocal.slice(0, 30).forEach(f => {
      const parts = f.fullPath.split(path.sep);
      const parentDir = parts[parts.length - 2] || '';
      report += `| \`${f.name}\` | \`${parentDir}\` | ${(f.size / 1024).toFixed(1)} KB |\n`;
    });
    if (unmatchedLocal.length > 30) {
      report += `\n*...and ${unmatchedLocal.length - 30} more unmatched files.*\n`;
    }
  }

  // Write report to artifact
  const reportPath = 'C:\\Users\\Durai Murugan\\.gemini\\antigravity-ide\\brain\\3d546ee1-70bf-49a0-be52-47b73b8dd45f\\image_analysis_report.md';
  fs.writeFileSync(reportPath, report);
  console.log(`\nReport written to artifact: ${reportPath}`);
}

main().catch(err => {
  console.error("Fatal error:", err);
});
