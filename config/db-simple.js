const { Pool } = require('pg');

console.log('🔌 Initializing PostgreSQL connection...');

// Check if we have DATABASE_URL (Render provides this)
let pool;

if (process.env.DATABASE_URL) {
  console.log('📊 Using DATABASE_URL connection string');
  pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    max: 3, // Very conservative
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
  });
} else {
  console.log('📊 Using individual environment variables');
  const config = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    max: 3,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 10000,
  };
  
  console.log('📊 Database config:', {
    host: config.host,
    port: config.port,
    database: config.database,
    user: config.user,
    password: config.password ? '***' : 'MISSING'
  });
  
  pool = new Pool(config);
}

// Connection event handlers
pool.on('connect', () => {
  console.log('✅ PostgreSQL client connected');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL pool error:', err.message);
});

// Test connection
const testConnection = async () => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    console.log('✅ PostgreSQL connection test successful:', result.rows[0]);
    client.release();
  } catch (err) {
    console.error('❌ PostgreSQL connection test failed:', err.message);
    console.error('🔍 Full error:', err);
  }
};

// Test after a delay
setTimeout(testConnection, 2000);

module.exports = pool;



