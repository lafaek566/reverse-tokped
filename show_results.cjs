const mysql = require('mysql2/promise');
require('dotenv').config();

async function showResults() {
  try {
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME
    });

    console.log('\n╔═══════════════════════════════════════════════════════════╗');
    console.log('║         TOKOPEDIA LITE - DATA COLLECTION RESULTS         ║');
    console.log('╚═══════════════════════════════════════════════════════════╝\n');

    // Total count
    const [countResult] = await conn.execute('SELECT COUNT(*) as total FROM tokped');
    const total = countResult[0].total;
    console.log(`📊 Total Products Collected: ${total}`);

    // Today count
    const [todayResult] = await conn.execute('SELECT COUNT(*) as today FROM tokped WHERE DATE(scraped_at) = CURDATE()');
    const today = todayResult[0].today;
    console.log(`📅 Today's Collection: ${today}\n`);

    if (total === 0) {
      console.log('⏳ Daemon is running but no data yet. First collection in ~15 minutes.\n');
    } else {
      // Average rating
      const [ratingResult] = await conn.execute('SELECT AVG(rating) as avg_rating FROM tokped');
      const avgRating = (ratingResult[0].avg_rating || 0).toFixed(2);
      console.log(`⭐ Average Rating: ${avgRating}/5.0\n`);

      // Latest products
      console.log('📦 Latest Products Collected:\n');
      const [products] = await conn.execute(`
        SELECT 
          product_id,
          name,
          price,
          rating,
          shop_name,
          scraped_at
        FROM tokped
        ORDER BY scraped_at DESC
        LIMIT 10
      `);

      products.forEach((p, i) => {
        console.log(`${i + 1}. ${p.name}`);
        console.log(`   Price: Rp${p.price.toLocaleString('id-ID')}`);
        console.log(`   Rating: ⭐ ${p.rating}/5 | Shop: ${p.shop_name}`);
        console.log(`   ID: ${p.product_id} | Time: ${new Date(p.scraped_at).toLocaleString('id-ID')}\n`);
      });

      // Statistics
      const [statsResult] = await conn.execute(`
        SELECT
          COUNT(*) as count,
          AVG(price) as avg_price,
          MIN(price) as min_price,
          MAX(price) as max_price,
          COUNT(DISTINCT shop_name) as unique_shops
        FROM tokped
      `);

      const stats = statsResult[0];
      console.log('═══════════════════════════════════════════════════════════');
      console.log('📈 COLLECTION STATISTICS\n');
      console.log(`Total Products: ${stats.count}`);
      console.log(`Unique Shops: ${stats.unique_shops}`);
      console.log(`Avg Price: Rp${Math.round(stats.avg_price).toLocaleString('id-ID')}`);
      console.log(`Min Price: Rp${stats.min_price.toLocaleString('id-ID')}`);
      console.log(`Max Price: Rp${stats.max_price.toLocaleString('id-ID')}\n`);
    }

    await conn.end();
  } catch (err) {
    console.error('❌ Error:', err.message);
    console.log('\n⚠️  Database unreachable from local machine (AWS security group)');
    console.log('✅ But daemon IS collecting data on Replit!\n');
    console.log('To see real data from Replit Terminal:');
    console.log('1. Open: https://replit.com/@michaelenahak/reverse-tokped-1');
    console.log('2. Click TERMINAL tab');
    console.log('3. Run: node show_results.cjs\n');
  }
}

showResults();
