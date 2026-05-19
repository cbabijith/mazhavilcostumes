import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Parse .env.local manually
const __dirname = path.dirname(fileURLToPath(import.meta.url));
try {
  const envPath = path.resolve(__dirname, '../apps/admin/.env.local');
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, 'utf-8');
    envContent.split('\n').forEach(line => {
      const parts = line.split('=');
      if (parts.length >= 2) {
        const key = parts[0].trim();
        const value = parts.slice(1).join('=').trim().replace(/^['"]|['"]$/g, '');
        if (key && value) {
          process.env[key] = value;
        }
      }
    });
  }
} catch (e) {
  console.error('Failed to parse .env.local', e);
}

import { reportService } from '../apps/admin/services/reportService';

async function testReportOutput() {
  console.log('\n======================================');
  console.log('TESTING GST FILING REPORT WITH ALL STATUSES');
  console.log('======================================');
  const resAll = await reportService.getGSTFilingReport({
    from_date: '2026-05-01',
    to_date: '2026-05-19',
    status: [],
    period: 'month',
    page: 1,
    limit: 50
  });

  console.log('Composition:', resAll.composition);
  console.log('Summary:', resAll.summary);
  console.log('Details Count:', resAll.details.length);

  console.log('\n======================================');
  console.log('TESTING GST FILING REPORT WITH COMPLETED/RETURNED STATUSES');
  console.log('======================================');
  const resCompleted = await reportService.getGSTFilingReport({
    from_date: '2026-05-01',
    to_date: '2026-05-19',
    status: ['completed', 'returned'],
    period: 'month',
    page: 1,
    limit: 50
  });

  console.log('Composition:', resCompleted.composition);
  console.log('Summary:', resCompleted.summary);
  console.log('Details Count:', resCompleted.details.length);
}

testReportOutput();
