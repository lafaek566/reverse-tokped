#!/usr/bin/env node

/**
 * Tokopedia API Scraper
 * Scrapes product data from Tokopedia using known GraphQL & REST APIs
 * 
 * Known Endpoints:
 * - gql.tokopedia.com (GraphQL) - Primary API
 * - ta.tokopedia.com (REST) - Alternative/backup
 * - www-gw.tokopedia.com (App Gateway)
 * 
 * Usage: node tokopedia_api_scraper.js
 */

const https = require('https');
const http = require('http');
const { URL } = require('url');

// Configuration
const CONFIG = {
  gql_endpoint: 'https://gql.tokopedia.com',
  rest_endpoint: 'https://ta.tokopedia.com',
  app_gateway: 'https://www-gw.tokopedia.com',
  timeout: 10000,
  retries: 3
};

// Headers for API requests
const getHeaders = (endpoint = 'graphql') => ({
  'Content-Type': 'application/json',
  'User-Agent': 'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  'Accept': 'application/json',
  'Accept-Encoding': 'gzip, deflate, br',
  'Accept-Language': 'en-US,en;q=0.9',
  'Sec-Fetch-Dest': 'empty',
  'Sec-Fetch-Mode': 'cors',
  'Sec-Fetch-Site': 'same-site',
  'X-Source': 'tokopedia-lite',
  'X-Version': '3.0',
  'Cache-Control': 'no-cache'
});

/**
 * Make HTTP(S) request
 */
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const protocol = urlObj.protocol === 'https:' ? https : http;
    
    const requestOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port,
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'POST',
      headers: options.headers || getHeaders(),
      timeout: CONFIG.timeout
    };

    const req = protocol.request(requestOptions, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(parsed);
          } else {
            reject(new Error(`HTTP ${res.statusCode}: ${data}`));
          }
        } catch (e) {
          reject(new Error(`Failed to parse response: ${e.message}`));
        }
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    req.end();
  });
}

/**
 * Search products using GraphQL
 */
async function searchProducts(keyword, page = 1) {
  console.log(`\n🔍 Searching for: "${keyword}" (page ${page})`);
  
  const query = {
    operationName: 'SearchProduct',
    variables: {
      keyword,
      first: 20,
      after: `${(page - 1) * 20}`,
      filter: {
        pmin: 0,
        pmax: 0
      },
      device: 'desktop'
    },
    query: `
      query SearchProduct($keyword: String!, $first: Int!, $after: String!, $filter: SearchProductFilter, $device: String) {
        searchProduct(keyword: $keyword, first: $first, after: $after, filter: $filter, device: $device) {
          products {
            id
            name
            price
            originalPrice
            discount
            rating
            countReview
            image {
              imageUrl
            }
            shop {
              id
              name
              rating
              isOfficial
            }
          }
          totalCount
        }
      }
    `
  };

  try {
    const response = await makeRequest(CONFIG.gql_endpoint, {
      method: 'POST',
      headers: getHeaders('graphql'),
      body: query
    });
    
    if (response.data?.searchProduct?.products) {
      const products = response.data.searchProduct.products;
      console.log(`✅ Found ${products.length} products`);
      return products;
    } else {
      console.warn('⚠️ No products in response');
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
async function getProductDetail(productId) {
  console.log(`\n📦 Getting details for product: ${productId}`);
  
  const query = {
    operationName: 'ProductDetail',
    variables: {
      productId: parseInt(productId)
    },
    query: `
      query ProductDetail($productId: Int!) {
        product(id: $productId) {
          id
          name
          description
          price
          originalPrice
          rating
          countReview
          stock
          image {
            imageUrl
          }
          shop {
            id
            name
            rating
            verified
          }
        }
      }
    `
  };

  try {
    const response = await makeRequest(CONFIG.gql_endpoint, {
      method: 'POST',
      headers: getHeaders('graphql'),
      body: query
    });
    
    if (response.data?.product) {
      console.log(`✅ Got details for: ${response.data.product.name}`);
      return response.data.product;
    } else {
      console.warn('⚠️ No product details in response');
      return null;
    }
  } catch (error) {
    console.error(`❌ Detail fetch failed: ${error.message}`);
    return null;
  }
}

/**
 * Get shop information
 */
async function getShopInfo(shopId) {
  console.log(`\n🏪 Getting shop info: ${shopId}`);
  
  const query = {
    operationName: 'ShopInfo',
    variables: {
      shopId: parseInt(shopId)
    },
    query: `
      query ShopInfo($shopId: Int!) {
        shop(id: $shopId) {
          id
          name
          description
          rating
          followers
          verified
          products {
            totalCount
          }
        }
      }
    `
  };

  try {
    const response = await makeRequest(CONFIG.gql_endpoint, {
      method: 'POST',
      headers: getHeaders('graphql'),
      body: query
    });
    
    if (response.data?.shop) {
      console.log(`✅ Got shop: ${response.data.shop.name}`);
      return response.data.shop;
    } else {
      console.warn('⚠️ No shop data in response');
      return null;
    }
  } catch (error) {
    console.error(`❌ Shop fetch failed: ${error.message}`);
    return null;
  }
}

/**
 * Test connectivity to Tokopedia API
 */
async function testConnectivity() {
  console.log('\n🧪 Testing Tokopedia API connectivity...\n');
  
  // Test simple query
  const testQuery = {
    operationName: 'TestQuery',
    variables: {},
    query: `
      query TestQuery {
        status
      }
    `
  };

  try {
    const response = await makeRequest(CONFIG.gql_endpoint, {
      method: 'POST',
      headers: getHeaders('graphql'),
      body: testQuery
    });
    
    console.log('✅ Connected to Tokopedia API');
    return true;
  } catch (error) {
    console.error(`❌ Connection failed: ${error.message}`);
    return false;
  }
}

/**
 * Main execution
 */
async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║     Tokopedia API Scraper - Known APIs Approach            ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  // Test connectivity
  const isConnected = await testConnectivity();
  if (!isConnected) {
    console.log('\n⚠️ Cannot connect to Tokopedia API. Check your internet connection.');
    process.exit(1);
  }

  // Example: Search for products
  console.log('\n📊 DEMO: Searching for products...\n');
  const products = await searchProducts('laptop', 1);
  
  if (products.length > 0) {
    console.log('\n📋 First 3 products:');
    products.slice(0, 3).forEach((product, idx) => {
      console.log(`\n  ${idx + 1}. ${product.name}`);
      console.log(`     Price: Rp${product.price}`);
      console.log(`     Rating: ${product.rating}⭐ (${product.countReview} reviews)`);
      console.log(`     Shop: ${product.shop.name}`);
    });

    // Get details for first product
    if (products[0]?.id) {
      const details = await getProductDetail(products[0].id);
      if (details) {
        console.log(`\n✅ Product details retrieved successfully`);
      }
    }
  }

  console.log('\n\n╔════════════════════════════════════════════════════════════╗');
  console.log('║                      ✅ SCRAPER READY                      ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  console.log('Functions available:');
  console.log('  - searchProducts(keyword, page)  → Search products');
  console.log('  - getProductDetail(productId)    → Get product info');
  console.log('  - getShopInfo(shopId)            → Get shop details\n');
}

// Export functions for use as module
module.exports = {
  searchProducts,
  getProductDetail,
  getShopInfo,
  testConnectivity,
  CONFIG
};

// Run if executed directly
if (require.main === module) {
  main().catch(console.error);
}
