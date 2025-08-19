const { Pool } = require('pg');

console.log('🔌 Initializing PostgreSQL connection...');

// Parse DATABASE_URL if available
let poolConfig = {};

if (process.env.DATABASE_URL) {
  console.log('📊 Using DATABASE_URL connection string');
  poolConfig = {
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false },
    // Very conservative settings for Render
    max: 2, // Maximum 2 connections
    min: 0, // Start with 0 connections
    idleTimeoutMillis: 10000, // Close idle connections after 10 seconds
    connectionTimeoutMillis: 5000, // Return error after 5 seconds
    acquireTimeoutMillis: 5000,
    reapIntervalMillis: 1000,
    createTimeoutMillis: 5000,
    destroyTimeoutMillis: 5000,
    // Better error handling
    allowExitOnIdle: false,
    // Connection retry settings
    maxRetries: 3,
    retryDelay: 1000
  };
} else {
  console.log('📊 Using individual environment variables');
  poolConfig = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: { rejectUnauthorized: false },
    // Same conservative settings
    max: 2,
    min: 0,
    idleTimeoutMillis: 10000,
    connectionTimeoutMillis: 5000,
    acquireTimeoutMillis: 5000,
    reapIntervalMillis: 1000,
    createTimeoutMillis: 5000,
    destroyTimeoutMillis: 5000,
    allowExitOnIdle: false,
    maxRetries: 3,
    retryDelay: 1000
  };
}

// Create the pool
const pool = new Pool(poolConfig);

// Connection event handlers
pool.on('connect', (client) => {
  console.log('✅ PostgreSQL client connected');
});

pool.on('acquire', (client) => {
  console.log('🔗 PostgreSQL client acquired from pool');
});

pool.on('release', (client) => {
  console.log('🔄 PostgreSQL client released back to pool');
});

pool.on('error', (err, client) => {
  console.error('❌ PostgreSQL pool error:', err.message);
  // Don't let the error crash the app
  if (client) {
    client.release();
  }
});

pool.on('remove', (client) => {
  console.log('🗑️ PostgreSQL client removed from pool');
});

// Test connection function
const testConnection = async () => {
  let client;
  try {
    client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    console.log('✅ PostgreSQL connection test successful:', result.rows[0]);
    return true;
  } catch (err) {
    console.error('❌ PostgreSQL connection test failed:', err.message);
    return false;
  } finally {
    if (client) {
      client.release();
    }
  }
};

// Test connection after a short delay
setTimeout(testConnection, 1000);

module.exports = pool;


