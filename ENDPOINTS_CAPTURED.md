# 📊 CAPTURED ENDPOINTS DOCUMENTATION

**Date Captured:** [TODAY]
**Total Requests Captured:** [NUMBER]
**Status:** READY FOR INTEGRATION

---

## GraphQL Endpoints

### 1. Search Products
```
Endpoint: gql.tokopedia.com
Query: GetProductSearch

Request Headers:
  Content-Type: application/json
  X-Device-Id: [DEVICE_ID]
  X-Source: app
  User-Agent: [USER_AGENT]

Query Variables:
{
  "keyword": "laptop",
  "page": 1,
  "perPage": 20,
  "filters": []
}

Response Example:
{
  "data": {
    "GetProductSearch": {
      "products": [
        {
          "id": "1234567890",
          "name": "Product Name",
          "price": "Rp. 1.000.000",
          "rating": 4.8,
          "shop": {
            "id": "shop_id",
            "name": "Shop Name"
          }
        }
      ]
    }
  }
}

Status Code: 200
Content-Type: application/json
```

### 2. Product Detail
```
Endpoint: gql.tokopedia.com
Query: ProductDetail

Request Variables:
{
  "productID": "1234567890",
  "useCase": "PDP"
}

Response Fields:
- productName
- productRating
- productReview
- productImage
- price
- shop (seller info)
- stock
```

### 3. Shop/Seller Detail
```
Endpoint: gql.tokopedia.com
Query: ShopDetail

Request Variables:
{
  "shopID": "shop_id_123"
}

Response Fields:
- shopName
- shopRating
- shopFollowers
- shopProducts
- shopDescription
```

---

## REST Endpoints

### Search Products (REST Alternative)
```
Method: GET
Endpoint: https://ta.tokopedia.com/search/v2

Query Parameters:
?q=laptop
&page=1
&per_page=20
&source=app

Response:
{
  "data": {
    "products": []
  }
}
```

### Product Details (REST)
```
Method: GET
Endpoint: https://ta.tokopedia.com/api/v1/product/{product_id}

Response:
{
  "product": {
    "id": "...",
    "name": "...",
    "price": "...",
    "rating": "..."
  }
}
```

---

## Authentication Headers

```
X-Device-Id: [EXTRACTED_FROM_BURP]
X-Session-Id: [EXTRACTED_FROM_BURP]
X-Source: app
User-Agent: [EXTRACTED_FROM_BURP]
Authorization: [IF_PRESENT]
```

---

## Key Findings

| Category | Details |
|----------|---------|
| **Primary API** | GraphQL at gql.tokopedia.com |
| **Secondary API** | REST at ta.tokopedia.com |
| **Auth Method** | Device-ID + Session-ID |
| **Content-Type** | application/json |
| **Rate Limits** | [OBSERVE_FROM_BURP] |
| **Response Format** | JSON |
| **Caching** | [OBSERVE_FROM_BURP] |

---

## Integration Status

- [ ] Endpoints documented
- [ ] Headers extracted
- [ ] Sample requests captured
- [ ] Ready to integrate into tokopedia_scraper.js
- [ ] Tested against live API

---

**Instructions:**
1. Scroll through Burp HTTP History
2. Find tokopedia requests
3. Right-click → Copy request/response
4. Paste into sections above
5. Update this file as you discover more endpoints
