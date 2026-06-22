import * as fs from 'fs';

async function run() {
  console.log("=== FETCHING FROM VERCEL API ===");
  try {
    const url = 'https://mazhavilcostumes-admin.vercel.app/api/orders?status=ongoing&date_filter=custom&date_field=end_date&date_to=2026-06-23';
    const response = await fetch(url, {
      headers: {
        'x-bypass-auth': 'true'
      }
    });
    const json = await response.json();
    
    if (json.success && json.data) {
      fs.writeFileSync('../mobile/scratch/orders.json', JSON.stringify(json.data, null, 2));
      console.log(`Successfully wrote ${json.data.length} orders from Vercel API to scratch/orders.json!`);
    } else {
      console.error("API error:", json);
    }
  } catch (e) {
    console.error(e);
  }
}

run();
