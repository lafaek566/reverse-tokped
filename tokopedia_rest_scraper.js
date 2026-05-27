#!/usr/bin/env node

/**
 * Tokopedia REST API Scraper - Simplified Version
 * Uses REST endpoints instead of GraphQL for better compatibility
 * 
 * Tested endpoints:
 * - /search/v2 (product search)
 * - /api/v1/product/{id} (product details)
 * - /api/v1/shop/{id} (shop info)
 */

const https = require('https');
const querystring = require('querystring');
const { URL } = require('url');

class TokopediaScraper {
  constructor() {
    this.baseUrl = 'https://ta.tokopedia.com';
    this.timeout = 15000;
    this.cache = {};
  }

  /**
   * Make HTTPS request
   */
  request(path, options = {}) {
    return new Promise((resolve, reject) => {
      const url = new URL(this.baseUrl + path);
      
      const requestOpts = {
        hostname: url.hostname,
        port: 443,
        path: url.pathname + url.search,
        method: options.method || 'GET',
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json, text/plain, */*',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'en-US,en;q=0.9',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
          'Sec-Fetch-Dest': 'empty',
          'Sec-Fetch-Mode': 'cors',
          'Sec-Fetch-Site': 'same-origin',
          ...options.headers
        },
        timeout: this.timeout
      };

      const req = https.request(requestOpts, (res) => {
        let data = '';
        
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve({ status: res.statusCode, data: parsed });
            } else {
              reject(new Error(`HTTP ${res.statusCode}`));
            }
          } catch (e) {
            resolve({ status: res.statusCode, data: data });
          }
        });
      });

      req.on('error', reject);
      req.on('timeout', () => {
        req.destroy();
        reject(new Error('Timeout'));
      });

      if (options.body) {
        req.write(JSON.stringify(options.body));
      }
      req.end();
    });
  }

  /**
   * Search products
   */
  async search(keyword, page = 1, limit = 20) {
    console.log(`\n🔍 Searching: "${keyword}" (page ${page})\n`);
    
    const params = {
      q: keyword,
      page,
      per_page: limit,
      source: 'search',
      sort: 'best_match',
      st: 'product'
    };

    const queryStr = querystring.stringify(params);
    
    try {
      const response = await this.request(`/search/v2?${queryStr}`);
      
      if (response.data?.data?.products) {
        const products = response.data.data.products;
        console.log(`✅ Found ${products.length} products\n`);
        return products;
      } else if (response.data?.products) {
        console.log(`✅ Found ${response.data.products.length} products\n`);
        return response.data.products;
      } else {
        console.log(`⚠️ Unexpected response format`);
        return [];
      }
    } catch (error) {
      console.error(`❌ Search failed: ${error.message}`);
      return [];
    }
  }

  /**
   * Get product details
   */
  async getProduct(productId) {
    console.log(`\n📦 Getting product: ${productId}`);
    
    try {
      const response = await this.request(`/api/v1/product/${productId}`);
      
      if (response.data?.data) {
        console.log(`✅ Got: ${response.data.data.name}\n`);
        return response.data.data;
      } else if (response.data?.product) {
        console.log(`✅ Got: ${response.data.product.name}\n`);
        return response.data.product;
      } else {
        return null;
      }
    } catch (error) {
      console.error(`❌ Error: ${error.message}\n`);
      return null;
    }
  }

  /**
   * Get shop details
   */
  async getShop(shopId) {
    console.log(`\n🏪 Getting shop: ${shopId}`);
    
    try {
      const response = await this.request(`/api/v1/shop/${shopId}`);
      
      if (response.data?.data) {
        console.log(`✅ Got: ${response.data.data.name}\n`);
        return response.data.data;
      } else {
        return null;
      }
    } catch (error) {
      console.error(`❌ Error: ${error.message}\n`);
      return null;
    }
  }

  /**
   * Test connectivity
   */
  async test() {
    console.log('\n🧪 Testing API connectivity...');
    try {
      const response = await this.request('/search/v2?q=phone&page=1&per_page=1');
      if (response.status === 200) {
        console.log('✅ Connected successfully\n');
        return true;
      }
    } catch (error) {
      console.error(`❌ Connection failed: ${error.message}\n`);
    }
    return false;
  }
}

/**
 * Main demo
 */
async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║     Tokopedia REST API Scraper v2                           ║');
  console.log('╚════════════════════════════════════════════════════════════╝');

  const scraper = new TokopediaScraper();

  // Test connection
  const isOnline = await scraper.test();
  if (!isOnline) {
    console.log('⚠️ Cannot reach Tokopedia API');
    process.exit(1);
  }

  // Search example
  const products = await scraper.search('smartphone', 1, 10);
  
  if (products.length > 0) {
    console.log('📋 Top 3 Results:');
    console.log('════════════════════════════════════════════════════════════');
    
    for (let i = 0; i < Math.min(3, products.length); i++) {
      const p = products[i];
      console.log(`\n${i + 1}. ${p.name || 'N/A'}`);
      console.log(`   💰 Price: ${p.price_int || p.price || 'N/A'}`);
      console.log(`   ⭐ Rating: ${p.rating || 'N/A'}`);
      console.log(`   🏪 Shop: ${p.shop?.name || p.shop || 'N/A'}`);
    }
    console.log('\n════════════════════════════════════════════════════════════');
  }

  console.log('\n✅ SCRAPER INITIALIZED AND READY\n');
  console.log('Methods available:');
  console.log('  scraper.search(keyword, page, limit)');
  console.log('  scraper.getProduct(productId)');
  console.log('  scraper.getShop(shopId)');
  console.log('  scraper.test()\n');
}

// Export for use as module
module.exports = TokopediaScraper;

// Run if executed directly
if (require.main === module) {
  main().catch(console.error);
}
