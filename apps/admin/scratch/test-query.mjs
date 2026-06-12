const supabaseUrl = 'https://szegcwbvvszsrmvzaiiv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN6ZWdjd2J2dnN6c3JtdnphaWl2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NzU4NTc4MiwiZXhwIjoyMDkzMTYxNzgyfQ.i1MrQtdzS4hY0zvCCdO43DIxqdC9t7FDBeD72vu4jnA';

async function run() {
  const query = 'a';
  // PostgREST syntax for OR filter: or=(name.ilike.%a%,email.ilike.%a%,phone.ilike.%a%)
  const url = `${supabaseUrl}/rest/v1/customers?select=*&or=(name.ilike.%25${query}%25,email.ilike.%25${query}%25,phone.ilike.%25${query}%25)&limit=20`;
  
  try {
    const res = await fetch(url, {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });
    
    if (!res.ok) {
      console.error('API Error:', res.status, await res.text());
      return;
    }
    
    const data = await res.json();
    console.log(`Matched count: ${data.length}`);
    console.log('Results:', data.map(c => ({ id: c.id, name: c.name, phone: c.phone })));
  } catch (err) {
    console.error('Fetch Error:', err);
  }
}

run();
