#!/usr/bin/env node

/**
 * 📊 Real-time Monitoring Dashboard
 * Display live daemon stats and database health
 */

const mysql = require('mysql2/promise');
require('dotenv').config();
const fs = require('fs');

const DB_CONFIG = {
  host: process.env.DB_HOST || 'alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'root',
  database: process.env.DB_NAME || 'tokped',
  port: 3306,
};

async function getDatabaseStats() {
  try {
    const connection = await mysql.createConnection(DB_CONFIG);

    // Total products
    const [countRows] = await connection.query('SELECT COUNT(*) as count FROM tokped');
    const totalCount = countRows[0].count;

    // Today's additions
    const [todayRows] = await connection.query(`
      SELECT COUNT(*) as count FROM tokped 
      WHERE DATE(scraped_at) = CURDATE()
    `);
    const todayCount = todayRows[0].count;

    // Latest update
    const [latestRows] = await connection.query(`
      SELECT MAX(updated_at) as last_update FROM tokped
    `);
    const lastUpdate = latestRows[0].last_update || 'Never';

    // Average rating
    const [ratingRows] = await connection.query(`
      SELECT AVG(rating) as avg_rating FROM tokped WHERE rating > 0
    `);
    const avgRating = ratingRows[0].avg_rating?.toFixed(2) || 'N/A';

    // Price stats
    const [priceRows] = await connection.query(`
      SELECT 
        MIN(price) as min_price,
        MAX(price) as max_price,
        AVG(price) as avg_price
      FROM tokped WHERE price > 0
    `);
    const priceStats = priceRows[0];

    await connection.end();
    return {
      total: totalCount,
      today: todayCount,
      lastUpdate,
      avgRating,
      minPrice: priceStats.min_price?.toLocaleString('id-ID', {style: 'currency', currency: 'IDR'}) || 'N/A',
      maxPrice: priceStats.max_price?.toLocaleString('id-ID', {style: 'currency', currency: 'IDR'}) || 'N/A',
      avgPrice: priceStats.avg_price?.toLocaleString('id-ID', {style: 'currency', currency: 'IDR'}) || 'N/A',
    };
  } catch (err) {
    return {
      error: err.message,
      total: 0,
      today: 0,
      lastUpdate: 'Error',
      avgRating: 'N/A',
    };
  }
}

function getDaemonStatus() {
  const logFile = 'daemon.log';
  if (!fs.existsSync(logFile)) return { status: 'Not started', lastRun: 'Never' };

  try {
    const logs = fs.readFileSync(logFile, 'utf8').split('\n');
    const lastLog = logs.filter(l => l).pop() || '';
    return {
      status: lastLog.includes('ERROR') ? '❌ Error' : '✅ Running',
      lastRun: lastLog,
    };
  } catch {
    return { status: 'Unknown', lastRun: 'N/A' };
  }
}

async function displayDashboard() {
  console.clear();
  console.log('\n' + '═'.repeat(60));
  console.log('     📊 TOKOPEDIA SCRAPER - MONITORING DASHBOARD');
  console.log('═'.repeat(60) + '\n');

  const stats = await getDatabaseStats();
  const daemon = getDaemonStatus();

  console.log('📡 DAEMON STATUS');
  console.log('─'.repeat(60));
  console.log(`Status: ${daemon.status}`);
  console.log(`Last Run: ${daemon.lastRun.substring(0, 80)}\n`);

  console.log('📊 DATABASE STATISTICS');
  console.log('─'.repeat(60));
  console.log(`Total Products:     ${stats.total} items`);
  console.log(`Added Today:        ${stats.today} items`);
  console.log(`Last Update:        ${stats.lastUpdate}\n`);

  console.log('⭐ QUALITY METRICS');
  console.log('─'.repeat(60));
  console.log(`Avg Rating:         ${stats.avgRating} / 5`);
  console.log(`Min Price:          ${stats.minPrice}`);
  console.log(`Avg Price:          ${stats.avgPrice}`);
  console.log(`Max Price:          ${stats.maxPrice}\n`);

  console.log('🚀 DEPLOYMENT INFO');
  console.log('─'.repeat(60));
  console.log(`Platform:           Replit`);
  console.log(`Server:             https://reverse-tokped-1.replit.dev`);
  console.log(`Database:           AWS RDS (tokped)`);
  console.log(`Update Interval:    Every 15 minutes`);
  console.log(`Status:             🟢 LIVE & OPERATIONAL\n`);

  console.log('═'.repeat(60));
  console.log('Updated:', new Date().toLocaleString('id-ID'));
  console.log('═'.repeat(60) + '\n');
}

// Run continuously
displayDashboard();
setInterval(displayDashboard, 30000); // Update every 30 seconds
