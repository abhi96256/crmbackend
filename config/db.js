const mysql = require('mysql2/promise');
const { Pool } = require('pg');

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'crm_db',
  charset: 'utf8mb4'
};

// PostgreSQL configuration with better connection handling
const pgConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'crm_db',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  
  // Connection pool settings
  max: 10, // Reduced from 20
  min: 1,  // Reduced from 2
  idleTimeoutMillis: 60000, // 1 minute
  connectionTimeoutMillis: 10000, // 10 seconds
  acquireTimeoutMillis: 10000,
  reapIntervalMillis: 1000,
  createTimeoutMillis: 10000,
  destroyTimeoutMillis: 5000,
  
  // Better error handling
  allowExitOnIdle: false,
  
  // Connection retry settings
  maxRetries: 3,
  retryDelay: 1000
};

let pool;

// Determine which database driver to use
if (process.env.DB_DRIVER === 'postgresql') {
  console.log('🔌 Using PostgreSQL driver');
  console.log('📊 Database config:', {
    host: pgConfig.host,
    port: pgConfig.port,
    database: pgConfig.database,
    user: pgConfig.user
  });
  
  pool = new Pool(pgConfig);
  
  // PostgreSQL connection event handlers
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
    console.error('❌ PostgreSQL pool error:', err);
    // Don't let the error crash the app
    if (client) {
      client.release();
    }
  });
  
  pool.on('remove', (client) => {
    console.log('🗑️ PostgreSQL client removed from pool');
  });
  
  // Test PostgreSQL connection with better error handling
  const testConnection = async () => {
    try {
      const client = await pool.connect();
      const result = await client.query('SELECT NOW()');
      console.log('✅ PostgreSQL connection test successful:', result.rows[0]);
      client.release();
    } catch (err) {
      console.error('❌ PostgreSQL connection test failed:', err.message);
      console.log('💡 Please check your PostgreSQL configuration on Render');
    }
  };
  
  // Test connection after a short delay
  setTimeout(testConnection, 1000);
  
} else {
  console.log('🔌 Using MySQL driver');
  pool = mysql.createPool({
    ...dbConfig,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    acquireTimeout: 30000,
    timeout: 60000,
    reconnect: true
  });
  
  // Test MySQL connection
  pool.execute('SELECT 1')
    .then(() => {
      console.log('✅ MySQL connection test successful');
    })
    .catch(err => {
      console.error('❌ MySQL connection test failed:', err.message);
      console.log('💡 Please make sure MySQL is running and database exists');
    });
}

// Export the pool
module.exports = pool; 