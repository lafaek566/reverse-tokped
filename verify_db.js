#!/usr/bin/env node

/**
 * 🔍 Database Verification Script
 * Check if Tokopedia daemon can connect to AWS RDS
 */

const mysql = require('mysql2/promise');
require('dotenv').config();

const DB_CONFIG = {
  host: process.env.DB_HOST || 'alpha.cqvy5bhjcd1n.ap-southeast-1.rds.amazonaws.com',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'root',
  database: process.env.DB_NAME || 'tokped',
  port: 3306,
};

async function verifyDatabase() {
  console.log('🔍 Testing Database Connection...');
  console.log(`📍 Host: ${DB_CONFIG.host}`);
  console.log(`👤 User: ${DB_CONFIG.user}`);
  console.log(`📊 Database: ${DB_CONFIG.database}`);
  console.log('-----------------------------------\n');

  try {
    const connection = await mysql.createConnection(DB_CONFIG);
    console.log('✅ Connection: SUCCESS\n');

    // Check table exists
    const [tables] = await connection.query("SHOW TABLES LIKE 'tokped'");
    if (tables.length === 0) {
      console.log('⚠️  Table "tokped" not found. Creating...');
      await connection.query(`
        CREATE TABLE IF NOT EXISTS tokped (
          id INT AUTO_INCREMENT PRIMARY KEY,
          product_id BIGINT UNIQUE,
          name VARCHAR(255),
          price DECIMAL(12, 2),
          rating FLOAT,
          shop_id BIGINT,
          shop_name VARCHAR(255),
          stock INT,
          scraped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      `);
      console.log('✅ Table created\n');
    } else {
      console.log('✅ Table: EXISTS\n');
    }

    // Get stats
    const [rows] = await connection.query('SELECT COUNT(*) as count FROM tokped');
    const count = rows[0].count;
    console.log(`📊 Total Products in Database: ${count}`);

    if (count > 0) {
      const [latest] = await connection.query('SELECT * FROM tokped ORDER BY updated_at DESC LIMIT 3');
      console.log('\n📋 Latest 3 Products:');
      latest.forEach((product, i) => {
        console.log(`\n${i + 1}. ${product.name}`);
        console.log(`   Price: Rp${product.price?.toLocaleString() || 'N/A'}`);
        console.log(`   Rating: ⭐ ${product.rating || 'N/A'}`);
        console.log(`   Shop: ${product.shop_name}`);
        console.log(`   Updated: ${product.updated_at}`);
      });
    }

    await connection.end();
    console.log('\n✅ DATABASE VERIFICATION COMPLETE\n');
    process.exit(0);

  } catch (err) {
    console.error('\n❌ CONNECTION FAILED:', err.message);
    console.error('\nTroubleshooting:');
    console.error('1. Check .env file has correct credentials');
    console.error('2. Verify AWS RDS security group allows MySQL (3306)');
    console.error('3. Confirm database "tokped" exists');
    console.error('4. Test with: mysql -h [host] -u [user] -p [db]');
    process.exit(1);
  }
}

verifyDatabase();
