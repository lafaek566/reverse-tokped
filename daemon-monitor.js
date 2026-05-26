#!/usr/bin/env node

/**
 * 🚂 Railway Daemon - Auto-update Tokopedia Merchant Data
 * Runs every 15 minutes automatically
 * Logs to console (visible in Railway dashboard)
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');
const querystring = require('querystring');

// Config
const UPDATE_INTERVAL = 15 * 60 * 1000; // 15 minutes
const LOG_FILE = 'daemon.log';

// DB Config (from environment)
const DB_CONFIG = {
  host: process.env.DB_HOST || 'alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || '',
  database: process.env.DB_NAME || 'vhelin',
  port: 3306,
};

const API_BASE = 'https://ta.tokopedia.com';

// Logger function
function log(level, msg) {
  const timestamp = new Date().toISOString();
  const logMsg = `[${timestamp}] [${level}] ${msg}`;
  console.log(logMsg);
  
  try {
    fs.appendFileSync(LOG_FILE, logMsg + '\n', 'utf8');
  } catch (err) {
    console.error('Log write failed:', err.message);
  }
}

// API call function
function apiCall(endpoint, params = {}) {
  return new Promise((resolve, reject) => {
    const queryStr = querystring.stringify(params);
    const url = `${API_BASE}${endpoint}${queryStr ? '?' + queryStr : ''}`;
    
    const options = {
      headers: {
        'X-Source': 'tokopedia-lite',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36',
        'Content-Type': 'application/json',
      },
      timeout: 10000,
    };

    https.get(url, options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (err) {
          reject(new Error(`JSON parse failed: ${err.message}`));
        }
      });
    }).on('error', reject);
  });
}

// Search Tokopedia products
async function searchProducts(keyword, page = 1, limit = 5) {
  try {
    const response = await apiCall('/search/v2', {
      q: keyword,
      page: page,
      limit: limit,
      sort: 'relevance',
    });

    if (!response.data || !response.data.products) {
      return [];
    }

    return response.data.products.map(p => ({
      product_id: p.product_id,
      name: p.name,
      price: p.price,
      rating: p.rating,
      shop_id: p.shop_id,
      shop_name: p.shop_name,
      stock: p.stock,
      scraped_at: new Date(),
    }));
  } catch (err) {
    log('ERROR', `Search failed: ${err.message}`);
    return [];
  }
}

// Database operations
async function saveToDatabase(products) {
  if (!process.env.DB_HOST) {
    log('WARN', 'Database not configured - skipping save');
    return 0;
  }

  try {
    const mysql = require('mysql2/promise');
    const connection = await mysql.createConnection(DB_CONFIG);
    
    let saved = 0;
    for (const product of products) {
      try {
        const query = `
          INSERT INTO shopee_merchants 
          (merchant_id, name, rating, address, latitude, longitude) 
          VALUES (?, ?, ?, ?, ?, ?)
          ON DUPLICATE KEY UPDATE 
          name = VALUES(name), 
          rating = VALUES(rating),
          updated_at = NOW()
        `;
        
        await connection.execute(query, [
          product.product_id,
          product.name,
          product.rating,
          product.shop_name,
          0,
          0,
        ]);
        
        saved++;
      } catch (err) {
        log('WARN', `Failed to save product ${product.product_id}: ${err.message}`);
      }
    }
    
    await connection.end();
    return saved;
  } catch (err) {
    log('ERROR', `Database error: ${err.message}`);
    return 0;
  }
}

// Main update function
async function runUpdate() {
  log('INFO', '═════════════════════════════════════');
  log('INFO', '🚂 Starting scheduled update...');
  
  const startTime = Date.now();
  
  try {
    // Search different keywords for variety
    const keywords = ['laptop', 'smartphone', 'headphones', 'tablet', 'gaming'];
    const randomKeyword = keywords[Math.floor(Math.random() * keywords.length)];
    
    log('INFO', `🔍 Searching for: ${randomKeyword}`);
    const products = await searchProducts(randomKeyword, 1, 10);
    
    if (products.length === 0) {
      log('WARN', 'No products found in search');
      return;
    }
    
    log('INFO', `✅ Found ${products.length} products`);
    
    // Save to database
    const saved = await saveToDatabase(products);
    log('INFO', `💾 Saved ${saved} products to database`);
    
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);
    log('INFO', `✅ Update completed in ${duration}s`);
    
  } catch (err) {
    log('ERROR', `Update failed: ${err.message}`);
  }
  
  log('INFO', '═════════════════════════════════════\n');
}

// Startup
log('INFO', '🚀 Railway Daemon Starting...');
log('INFO', `📊 Update interval: ${UPDATE_INTERVAL / 60000} minutes`);
log('INFO', `📍 Database: ${DB_CONFIG.host}:${DB_CONFIG.port}/${DB_CONFIG.database}`);
log('INFO', `🌍 Environment: ${process.env.NODE_ENV || 'production'}`);
log('INFO', '─────────────────────────────────────');

// Start HTTP server (required for Fly.io)
const PORT = process.env.PORT || 3000;
const server = http.createServer((req, res) => {
  if (req.url === '/health' || req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
      status: 'ok', 
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, '0.0.0.0', () => {
  log('INFO', `✅ HTTP server listening on port ${PORT}`);
});

// Run first update immediately
runUpdate();

// Then schedule recurring updates
const intervalId = setInterval(runUpdate, UPDATE_INTERVAL);

// Graceful shutdown
process.on('SIGTERM', () => {
  log('INFO', '⚠️ SIGTERM received - shutting down gracefully...');
  clearInterval(intervalId);
  server.close(() => {
    log('INFO', 'HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  log('INFO', '⚠️ SIGINT received - shutting down gracefully...');
  clearInterval(intervalId);
  server.close(() => {
    log('INFO', 'HTTP server closed');
    process.exit(0);
  });
});

// Error handling
process.on('unhandledRejection', (reason) => {
  log('ERROR', `Unhandled rejection: ${reason}`);
});

process.on('uncaughtException', (err) => {
  log('ERROR', `Uncaught exception: ${err.message}`);
  process.exit(1);
});

log('INFO', '✅ Daemon ready! Waiting for scheduled updates...');
