import { productRepository } from '../repository/productRepository';
import { orderRepository } from '../repository/orderRepository';

/**
 * Initialization script to sync stock conflicts for all products.
 * Use this to catch up existing orders after implementing the alerting system.
 */
async function syncAllConflicts() {
  console.log('🚀 Starting global stock conflict synchronization...');
  
  // 1. Fetch all product IDs
  const { data: products, error: pError } = await productRepository.findAll();
  
  if (pError || !products) {
    console.error('❌ Failed to fetch products:', pError);
    return;
  }

  const productList = products.products;
  console.log(`📦 Found ${productList.length} products to check.`);

  // 2. Sync conflicts for each product
  let processed = 0;
  for (const product of productList) {
    process.stdout.write(`🔄 Syncing: ${product.name}... `);
    try {
      await orderRepository.syncProductConflicts(product.id);
      console.log('✅');
      processed++;
    } catch (err) {
      console.log('❌');
      console.error(`   Error syncing product ${product.id}:`, err);
    }
  }

  console.log(`\n✨ Finished! Processed ${processed}/${productList.length} products.`);
  process.exit(0);
}

syncAllConflicts().catch(err => {
  console.error('💥 Fatal error:', err);
  process.exit(1);
});
