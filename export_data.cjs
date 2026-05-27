#!/usr/bin/env node

/**
 * 💾 Data Export & Backup Script
 * Export database to CSV and JSON formats
 */

const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const DB_CONFIG = {
  host: process.env.DB_HOST || 'alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'root',
  database: process.env.DB_NAME || 'tokped',
  port: 3306,
};

async function exportData() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5);
  const exportDir = 'exports';

  if (!fs.existsSync(exportDir)) {
    fs.mkdirSync(exportDir);
  }

  try {
    const connection = await mysql.createConnection(DB_CONFIG);
    const [rows] = await connection.query('SELECT * FROM tokped ORDER BY updated_at DESC');

    // JSON Export
    const jsonFile = path.join(exportDir, `tokped-${timestamp}.json`);
    fs.writeFileSync(jsonFile, JSON.stringify(rows, null, 2));
    console.log(`✅ JSON exported: ${jsonFile} (${rows.length} products)`);

    // CSV Export
    const csvFile = path.join(exportDir, `tokped-${timestamp}.csv`);
    const headers = Object.keys(rows[0] || {});
    const csvContent = [
      headers.join(','),
      ...rows.map(row =>
        headers.map(h => {
          const val = row[h];
          if (val === null) return '';
          if (typeof val === 'string' && val.includes(',')) return `"${val}"`;
          return val;
        }).join(',')
      ),
    ].join('\n');
    fs.writeFileSync(csvFile, csvContent);
    console.log(`✅ CSV exported: ${csvFile} (${rows.length} products)`);

    // Summary Report
    const [countByShop] = await connection.query(`
      SELECT shop_name, COUNT(*) as count
      FROM tokped
      GROUP BY shop_name
      ORDER BY count DESC
    `);

    const reportFile = path.join(exportDir, `report-${timestamp}.txt`);
    const report = `
TOKOPEDIA SCRAPER - DATA EXPORT REPORT
Generated: ${new Date().toLocaleString('id-ID')}
=====================================

SUMMARY STATISTICS:
- Total Products: ${rows.length}
- Date Range: ${rows[rows.length - 1]?.scraped_at} to ${rows[0]?.scraped_at}
- Average Rating: ${(rows.reduce((sum, r) => sum + (r.rating || 0), 0) / rows.length).toFixed(2)}

TOP SHOPS BY PRODUCT COUNT:
${countByShop.map((s, i) => `${i + 1}. ${s.shop_name}: ${s.count} products`).join('\n')}

EXPORTED FILES:
- JSON: ${path.basename(jsonFile)}
- CSV: ${path.basename(csvFile)}
- Report: ${path.basename(reportFile)}
    `;
    fs.writeFileSync(reportFile, report);
    console.log(`✅ Report saved: ${reportFile}`);

    // Keep only last 10 exports
    const files = fs.readdirSync(exportDir).sort().reverse();
    files.slice(30).forEach(f => {
      fs.unlinkSync(path.join(exportDir, f));
    });

    await connection.end();
    console.log('\n✅ EXPORT COMPLETE\n');

  } catch (err) {
    console.error('❌ Export failed:', err.message);
    process.exit(1);
  }
}

exportData();
