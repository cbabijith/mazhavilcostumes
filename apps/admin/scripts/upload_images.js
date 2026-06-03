const { createClient } = require('@supabase/supabase-js');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const fs = require('fs');
const path = require('path');

// Configuration
let envPath = '.env.local';
if (!fs.existsSync(envPath)) {
  envPath = '../.env.local'; // Fallback if run from scripts dir
}
if (!fs.existsSync(envPath)) {
  envPath = 'apps/admin/.env.local'; // Fallback if run from root
}

if (!fs.existsSync(envPath)) {
  console.error("Could not find .env.local");
  process.exit(1);
}

const envContent = fs.readFileSync(envPath, 'utf8');
const env = {};
envContent.split('\n').forEach(line => {
  const parts = line.split('=');
  if (parts.length >= 2) {
    const key = parts[0].trim();
    const val = parts.slice(1).join('=').trim();
    env[key] = val;
  }
});

const supabaseUrl = env['NEXT_PUBLIC_SUPABASE_URL'];
const supabaseServiceKey = env['SUPABASE_SERVICE_ROLE_KEY'];
const r2Endpoint = env['R2_ENDPOINT'];
const r2AccessKeyId = env['R2_ACCESS_KEY_ID'];
const r2SecretAccessKey = env['R2_SECRET_ACCESS_KEY'];
const r2BucketName = env['R2_BUCKET_NAME'] || 'praisbridals';
const r2PublicUrl = env['R2_PUBLIC_URL'];

if (!supabaseUrl || !supabaseServiceKey || !r2Endpoint || !r2AccessKeyId || !r2SecretAccessKey || !r2PublicUrl) {
  console.error("Missing required environment variables in .env.local");
  process.exit(1);
}

// Clients
const supabase = createClient(supabaseUrl, supabaseServiceKey);
const s3 = new S3Client({
  region: 'auto',
  endpoint: r2Endpoint,
  credentials: {
    accessKeyId: r2AccessKeyId,
    secretAccessKey: r2SecretAccessKey
  }
});

// Helper: Get MIME Content-Type
function getContentType(ext) {
  switch (ext) {
    case '.png': return 'image/png';
    case '.webp': return 'image/webp';
    case '.jpeg':
    case '.jpg':
    default:
      return 'image/jpeg';
  }
}

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

// Paginating product fetch to get all 1744 products
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

function generateR2Key(folder, filename) {
  const timestamp = Date.now();
  const sanitizedFilename = filename.replace(/[^a-zA-Z0-9.-]/g, "_");
  return `${folder}/${timestamp}-${sanitizedFilename}`;
}

async function main() {
  console.log("=== STEP 1: SCANNING LOCAL IMAGES ===");
  const localImagesDir = "D:\\personal\\mazhavil images";
  const localFiles = getFilesRecursively(localImagesDir);
  console.log(`Found ${localFiles.length} image files locally.`);

  const localFilesMap = new Map();
  for (const f of localFiles) {
    const key = f.baseName.trim().toLowerCase();
    if (!localFilesMap.has(key)) {
      localFilesMap.set(key, []);
    }
    localFilesMap.get(key).push(f);
  }

  console.log("\n=== STEP 2: FETCHING PRODUCTS ===");
  const products = await fetchAllProducts();
  console.log(`Fetched total of ${products.length} products from database.`);

  console.log("\n=== STEP 3: MATCHING AND RESILIENT UPLOADING ===");
  const toProcess = [];

  for (const product of products) {
    // Skip if product already has image in DB (allows clean resumes)
    const hasImage = Array.isArray(product.images) && product.images.length > 0;
    if (hasImage) {
      continue;
    }

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

    if (matchedFiles && matchedFiles.length > 0) {
      toProcess.push({
        product,
        file: matchedFiles[0] // Take the first matched image file
      });
    }
  }

  console.log(`Matched ${toProcess.length} products remaining to upload.`);
  
  let successCount = 0;
  let failureCount = 0;
  let currentIndex = 0;
  const concurrencyLimit = 4; // Low concurrency to guarantee 100% socket stability
  const maxRetries = 5;

  async function worker() {
    while (currentIndex < toProcess.length) {
      const idx = currentIndex++;
      const { product, file } = toProcess[idx];
      const progress = `[${idx + 1}/${toProcess.length}]`;
      
      let attempts = 0;
      let isSuccess = false;
      let lastError = null;
      let publicUrl = '';

      while (attempts < maxRetries && !isSuccess) {
        try {
          attempts++;
          
          // Read local file
          const fileBuffer = fs.readFileSync(file.fullPath);
          const contentType = getContentType(file.ext);
          
          // Generate key and upload
          const key = generateR2Key('products', file.name);
          
          const uploadParams = {
            Bucket: r2BucketName,
            Key: key,
            Body: fileBuffer,
            ContentType: contentType
          };

          await s3.send(new PutObjectCommand(uploadParams));
          publicUrl = `${r2PublicUrl}/${key}`;

          // Construct images payload
          const imagesPayload = [
            {
              url: publicUrl,
              alt_text: product.name,
              is_primary: true,
              sort_order: 0
            }
          ];

          // Update in DB
          const { error } = await supabase
            .from('products')
            .update({ images: imagesPayload })
            .eq('id', product.id);

          if (error) {
            throw new Error(`Supabase update error: ${error.message}`);
          }

          isSuccess = true;
        } catch (err) {
          lastError = err;
          if (attempts < maxRetries) {
            const backoff = attempts * 1000;
            console.warn(`   ⚠️  Attempt ${attempts} failed for ${file.name}: ${err.message}. Retrying in ${backoff}ms...`);
            await new Promise(resolve => setTimeout(resolve, backoff));
          }
        }
      }

      if (isSuccess) {
        console.log(`   └─ Success ${progress}: ${file.name} -> ${publicUrl}`);
        successCount++;
      } else {
        console.error(`   ❌ Failed ${progress} after ${maxRetries} attempts (${file.name}): ${lastError.message}`);
        failureCount++;
      }
    }
  }

  // Start concurrent workers
  console.log(`Starting upload queue with concurrency limit of ${concurrencyLimit} workers...`);
  const workers = Array.from({ length: concurrencyLimit }, () => worker());
  await Promise.all(workers);

  console.log(`\n=== UPLOAD JOB COMPLETED ===`);
  console.log(`Successfully processed: ${successCount}`);
  console.log(`Failed: ${failureCount}`);
  console.log(`Total remaining processed: ${toProcess.length}`);
}

main().catch(err => {
  console.error("Fatal error:", err);
});
