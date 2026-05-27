#!/usr/bin/env node

/**
 * Tokopedia Product Scraper
 * Reverse-engineered from APK analysis + public API research
 * Uses known GraphQL and REST endpoints
 */

const https = require('https');
const http = require('http');
const crypto = require('crypto');

// ============================================
// TOKOPEDIA API ENDPOINTS & CONFIGURATION
// ============================================

const API_CONFIG = {
  // GraphQL Endpoint (primary)
  graphql: 'https://gql.tokopedia.com/graphql',
  
  // REST API Endpoints
  api: {
    // Product Discovery
    search: 'https://ta.tokopedia.com/search/v2.8/',
    product: 'https://ta.tokopedia.com/product/',
    productDetail: 'https://gql.tokopedia.com/',
    
    // Shop/Merchant
    shop: 'https://ta.tokopedia.com/shop/',
    shopInfo: 'https://gql.tokopedia.com/',
    
    // Reviews & Ratings  
    reviews: 'https://ta.tokopedia.com/review/',
    
    // Cart & Checkout
    cart: 'https://ta.tokopedia.com/cart/',
    
    // User Auth
    auth: 'https://accounts.tokopedia.com/',
  },
  
  // Headers for requests
  headers: {
    'User-Agent': 'Tokopedia/440500 (Linux; Android 14; SM-G950F) okhttp/4.11.0',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9',
    'Content-Type': 'application/json',
    'X-Device': 'Android',
    'X-App-Version': '44.5.0',
    'X-Source': 'android-app',
    'DNT': '1',
    'Connection': 'keep-alive',
  }
};

// ============================================
// GraphQL Queries
// ============================================

const GraphQL_Queries = {
  // Product Search Query
  searchProducts: `query ProductSearch($query: String!, $first: Int!, $after: String, $sort: String) {
    productSearch(query: $query, first: $first, after: $after, sort: $sort) {
      edges {
        node {
          id
          name
          price
          rating
          image
          shop {
            id
            name
            rating
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }`,
  
  // Product Detail Query
  productDetail: `query ProductDetail($id: ID!) {
    product(id: $id) {
      id
      name
      description
      price
      originalPrice
      discount
      rating
      reviews {
        totalCount
        averageScore
      }
      seller {
        id
        name
        rating
        location
      }
      variants {
        id
        name
        price
      }
    }
  }`,
  
  // Shop Info Query
  shopInfo: `query ShopInfo($id: ID!) {
    shop(id: $id) {
      id
      name
      description
      rating
      followers
      location
      verified
      products {
        totalCount
      }
    }
  }`,
};

// ============================================
// SCRAPER CLASS
// ============================================

class TokopediaScraper {
  constructor(options = {}) {
    this.config = { ...API_CONFIG, ...options };
    this.session = {
      deviceId: this.generateDeviceId(),
      sessionId: this.generateSessionId(),
      timestamp: Date.now(),
    };
    this.cache = {};
  }

  /**
   * Generate Device ID (mimics Android device)
   */
  generateDeviceId() {
    const chars = '0123456789ABCDEF';
    let id = '';
    for (let i = 0; i < 16; i++) {
      id += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return id;
  }

  /**
   * Generate Session ID
   */
  generateSessionId() {
    return crypto.randomBytes(16).toString('hex');
  }

  /**
   * Make HTTP request with proper headers & auth
   */
  async request(url, options = {}) {
    return new Promise((resolve, reject) => {
      const urlObj = new URL(url);
      const isHttps = url.startsWith('https');
      const client = isHttps ? https : http;

      const requestOptions = {
        hostname: urlObj.hostname,
        port: urlObj.port,
        path: urlObj.pathname + urlObj.search,
        method: options.method || 'GET',
        headers: {
          ...this.config.headers,
          'X-Device-ID': this.session.deviceId,
          'X-Session-ID': this.session.sessionId,
          ...options.headers,
        },
        timeout: 15000,
      };

      const req = client.request(requestOptions, (res) => {
        let data = '';
        res.on('data', chunk => { data += chunk; });
        res.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            resolve({ status: res.statusCode, data: parsed, headers: res.headers });
          } catch (e) {
            resolve({ status: res.statusCode, data: data, headers: res.headers });
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
   * Execute GraphQL Query
   */
  async graphql(query, variables = {}) {
    const body = {
      operationName: Object.keys(GraphQL_Queries).find(key => GraphQL_Queries[key] === query),
      query,
      variables,
    };

    const response = await this.request(this.config.graphql, {
      method: 'POST',
      body,
    });

    return response.data;
  }

  /**
   * Search Products
   */
  async searchProducts(query, options = {}) {
    console.log(`🔍 Searching for: "${query}"`);
    
    const variables = {
      query,
      first: options.first || 20,
      after: options.after || null,
      sort: options.sort || 'relevance',
    };

    try {
      const result = await this.graphql(GraphQL_Queries.searchProducts, variables);
      console.log(`✅ Found ${result.data.productSearch.edges.length} products`);
      return result.data.productSearch;
    } catch (error) {
      console.error(`❌ Search failed: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get Product Details
   */
  async getProductDetail(productId) {
    console.log(`📦 Fetching product: ${productId}`);
    
    try {
      const result = await this.graphql(GraphQL_Queries.productDetail, { id: productId });
      console.log(`✅ Retrieved product: ${result.data.product.name}`);
      return result.data.product;
    } catch (error) {
      console.error(`❌ Failed to get product: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get Shop Info
   */
  async getShopInfo(shopId) {
    console.log(`🏪 Fetching shop: ${shopId}`);
    
    try {
      const result = await this.graphql(GraphQL_Queries.shopInfo, { id: shopId });
      console.log(`✅ Retrieved shop: ${result.data.shop.name}`);
      return result.data.shop;
    } catch (error) {
      console.error(`❌ Failed to get shop: ${error.message}`);
      throw error;
    }
  }

  /**
   * Batch Scrape Products
   */
  async batchScrape(queries, options = {}) {
    console.log(`\n📊 Starting batch scrape for ${queries.length} queries...`);
    
    const results = [];
    for (const q of queries) {
      try {
        const products = await this.searchProducts(q);
        results.push({
          query: q,
          count: products.edges.length,
          products: products.edges.map(e => e.node),
        });
        
        // Rate limiting
        await new Promise(r => setTimeout(r, options.delay || 1000));
      } catch (error) {
        console.warn(`⚠️  Query "${q}" failed: ${error.message}`);
      }
    }
    
    console.log(`\n✅ Batch scrape complete!`);
    return results;
  }
}

// ============================================
// USAGE EXAMPLE
// ============================================

async function main() {
  const scraper = new TokopediaScraper();

  try {
    // Example 1: Search products
    console.log('\n=== EXAMPLE 1: Search Products ===');
    const searchResults = await scraper.searchProducts('laptop', { first: 5 });
    console.log(JSON.stringify(searchResults, null, 2));

    // Example 2: Get product detail
    if (searchResults.edges.length > 0) {
      console.log('\n=== EXAMPLE 2: Product Detail ===');
      const productId = searchResults.edges[0].node.id;
      const details = await scraper.getProductDetail(productId);
      console.log(JSON.stringify(details, null, 2));
    }

    // Example 3: Batch scrape
    console.log('\n=== EXAMPLE 3: Batch Scrape ===');
    const queries = ['smartphone', 'headphone', 'tablet'];
    const batch = await scraper.batchScrape(queries, { delay: 500 });
    console.log(JSON.stringify(batch, null, 2));

  } catch (error) {
    console.error('❌ Error:', error);
  }
}

// Export for use as module
module.exports = { TokopediaScraper, API_CONFIG };

// Run if executed directly
if (require.main === module) {
  main().catch(console.error);
}
