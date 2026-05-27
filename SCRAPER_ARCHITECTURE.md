# Tokopedia Scraper - Production Architecture

## Project Structure
```
tokopedia_scraper/
├── src/
│   ├── config/
│   │   ├── api.config.js          # API endpoints & headers
│   │   ├── database.config.js     # Database credentials
│   │   └── proxy.config.js        # Proxy settings
│   ├── scrapers/
│   │   ├── ProductScraper.js      # Product data
│   │   ├── MerchantScraper.js     # Shop/merchant info
│   │   └── ReviewScraper.js       # Reviews & ratings
│   ├── models/
│   │   ├── Product.js             # Product data model
│   │   ├── Merchant.js            # Merchant data model
│   │   └── Review.js              # Review data model
│   ├── database/
│   │   ├── db.js                  # Database connection
│   │   └── migrations.js          # DB schema setup
│   ├── utils/
│   │   ├── logger.js              # Logging
│   │   ├── retry.js               # Retry logic
│   │   ├── cache.js               # Caching layer
│   │   └── validator.js           # Data validation
│   ├── services/
│   │   ├── api.service.js         # API calls with retry/proxy
│   │   ├── export.service.js      # Export to CSV/JSON
│   │   └── monitor.service.js     # Monitoring/stats
│   ├── workers/
│   │   ├── scrape.worker.js       # Batch scraping
│   │   └── monitor.daemon.js      # Long-running monitor
│   └── index.js                   # Main entry
├── tests/
│   ├── scrapers.test.js           # Unit tests
│   └── integration.test.js        # Integration tests
├── .env.example                   # Environment variables
├── package.json                   # Dependencies
├── README.md                       # Documentation
└── docker-compose.yml             # Docker setup (optional)
```

## Database Schema

### Products Table
```sql
CREATE TABLE products (
  id BIGINT PRIMARY KEY,
  name VARCHAR(500),
  price DECIMAL(12, 2),
  original_price DECIMAL(12, 2),
  discount INT,
  rating FLOAT,
  review_count INT,
  sold_count INT,
  merchant_id BIGINT,
  url VARCHAR(500),
  image_url VARCHAR(500),
  description TEXT,
  category VARCHAR(200),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (merchant_id) REFERENCES merchants(id)
);
```

### Merchants Table  
```sql
CREATE TABLE merchants (
  id BIGINT PRIMARY KEY,
  name VARCHAR(300),
  rating FLOAT,
  followers INT,
  products_count INT,
  location VARCHAR(200),
  verified BOOLEAN,
  response_time INT,
  response_rate FLOAT,
  url VARCHAR(500),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Reviews Table
```sql
CREATE TABLE reviews (
  id BIGINT PRIMARY KEY,
  product_id BIGINT,
  rating INT,
  comment TEXT,
  reviewer_name VARCHAR(200),
  helpful_count INT,
  created_at TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
```

## API Endpoints (Known Tokopedia)

### GraphQL Endpoint
- URL: `https://gql.tokopedia.com/graphql`
- Auth: X-Device-ID, X-Session-ID headers
- Rate Limit: ~60req/min (estimated)

### REST Endpoints
- Search: `https://ta.tokopedia.com/search/v2.8/`
- Product: `https://ta.tokopedia.com/product/`
- Reviews: `https://ta.tokopedia.com/review/`
- Shop: `https://ta.tokopedia.com/shop/`

## Anti-Bot Bypass Strategies

1. **Proxy Rotation** - Use residential proxies (ProxyMesh, etc)
2. **User-Agent Rotation** - Randomize device/OS
3. **Request Throttling** - Add random delays (1-3 sec)
4. **Session Management** - Rotate Device IDs
5. **Retry Logic** - Exponential backoff on errors
6. **VPN/Cloud** - Run from different IP locations

## Deployment Options

### Option 1: Local (Current)
- Dev/test environment
- Limited by local IP blocking
- Good for development

### Option 2: Cloud VPS (Recommended)
- DigitalOcean / AWS / GCP
- Fresh IP, better success rate
- Cost: $5-20/month
- Auto-scaling available

### Option 3: Serverless (AWS Lambda)
- Pay-per-use
- Auto-scaling
- Good for batch jobs

## Monitoring & Alerts

```
Metrics to track:
- Successful requests / failures
- Average response time
- Data quality (missing fields, etc)
- Rate limit status
- IP block detection
- Database update frequency
```

## Next Steps

1. ✅ Create database schema
2. ✅ Build API wrapper with proxy support
3. ✅ Implement retry logic & rate limiting
4. ✅ Create data models & validation
5. ✅ Build export utilities
6. ✅ Setup monitoring dashboard
7. ✅ Deploy to cloud (VPS/Lambda)
8. ✅ Configure auto-updates

---

**Status:** Ready for implementation
**Blocker:** Tokopedia anti-bot detection (solved via proxy/cloud)
**Est. Time to Full Production:** 4-6 hours
