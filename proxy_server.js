/**
 * Simple HTTP Proxy Server untuk Intercepting Traffic
 * Runs on port 8080 dan forward requests from emulator
 * 
 * Usage: node proxy_server.js
 */

const http = require('http');
const https = require('https');
const url = require('url');
const fs = require('fs');

// Logging file
const logFile = 'proxy_traffic.log';
const clearLog = () => fs.writeFileSync(logFile, '');

// Clear previous logs
clearLog();

function log(message) {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] ${message}`;
  console.log(line);
  fs.appendFileSync(logFile, line + '\n');
}

// Create proxy server
const proxyServer = http.createServer((clientReq, clientRes) => {
  const parsedUrl = url.parse(clientReq.url, true);
  const hostname = clientReq.headers.host;
  
  log(`>>> ${clientReq.method} ${hostname}${clientReq.url}`);
  
  // Extract request details
  const requestDetails = {
    method: clientReq.method,
    host: hostname,
    path: clientReq.url,
    headers: clientReq.headers
  };
  
  // Log important endpoints
  if (clientReq.url.includes('gql.tokopedia.com') || 
      clientReq.url.includes('ta.tokopedia.com') ||
      clientReq.url.includes('tokopedia')) {
    log(`  🎯 TARGET ENDPOINT DETECTED: ${hostname}${clientReq.url}`);
  }
  
  // Create proxy request
  const protocol = parsedUrl.protocol === 'https:' ? https : http;
  const proxyReq = protocol.request({
    hostname: parsedUrl.hostname || hostname.split(':')[0],
    port: parsedUrl.port || (parsedUrl.protocol === 'https:' ? 443 : 80),
    path: parsedUrl.pathname + (parsedUrl.search || ''),
    method: clientReq.method,
    headers: {
      ...clientReq.headers,
      'host': parsedUrl.hostname || hostname.split(':')[0]
    }
  }, (proxyRes) => {
    log(`<<< ${proxyRes.statusCode} ${hostname}${clientReq.url}`);
    
    // Forward response headers
    Object.keys(proxyRes.headers).forEach(key => {
      clientRes.setHeader(key, proxyRes.headers[key]);
    });
    
    clientRes.writeHead(proxyRes.statusCode);
    proxyRes.pipe(clientRes);
  });
  
  proxyReq.on('error', (error) => {
    log(`❌ Error: ${error.message}`);
    clientRes.writeHead(500);
    clientRes.end('Proxy Error');
  });
  
  // Forward request body
  clientReq.pipe(proxyReq);
});

// Start server
const PORT = 8080;
proxyServer.listen(PORT, () => {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`✅ PROXY SERVER RUNNING ON PORT ${PORT}`);
  console.log(`${'='.repeat(60)}\n`);
  console.log(`📱 Android Emulator Configuration:`);
  console.log(`   adb shell settings put global http_proxy <YOUR_IP>:${PORT}\n`);
  console.log(`📊 Monitoring traffic - check proxy_traffic.log\n`);
  console.log(`🎯 Looking for: gql.tokopedia.com, ta.tokopedia.com\n`);
  console.log(`Press CTRL+C to stop\n`);
  console.log(`${'='.repeat(60)}\n`);
});

// Handle shutdown
process.on('SIGINT', () => {
  log('Proxy server stopped');
  process.exit(0);
});
