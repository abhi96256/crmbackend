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

// PostgreSQL configuration
const pgConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'crm_db',
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  // Better connection handling
  max: 20,
  min: 2,
  idleTimeoutMillis: 300000, // 5 minutes
  connectionTimeoutMillis: 30000, // 30 seconds
  acquireTimeoutMillis: 30000,
  reapIntervalMillis: 1000,
  createTimeoutMillis: 30000,
  destroyTimeoutMillis: 5000,
  // Connection retry settings
  maxRetries: 3,
  retryDelay: 1000
};

let pool;

// Determine which database driver to use
if (process.env.DB_DRIVER === 'postgresql') {
  console.log('Using PostgreSQL driver');
  pool = new Pool(pgConfig);
  
  // PostgreSQL connection event handlers
  pool.on('connect', (client) => {
    console.log('PostgreSQL client connected');
  });
  
  pool.on('acquire', (client) => {
    console.log('PostgreSQL client acquired from pool');
  });
  
  pool.on('release', (client) => {
    console.log('PostgreSQL client released back to pool');
  });
  
  pool.on('error', (err, client) => {
    console.error('PostgreSQL pool error:', err);
  });
  
  pool.on('remove', (client) => {
    console.log('PostgreSQL client removed from pool');
  });
  
  // Test PostgreSQL connection
  pool.query('SELECT NOW()', (err, res) => {
    if (err) {
      console.error('PostgreSQL connection test failed:', err);
    } else {
      console.log('PostgreSQL connection test successful:', res.rows[0]);
    }
  });
} else {
  console.log('Using MySQL driver');
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
      console.log('MySQL connection test successful');
    })
    .catch(err => {
      console.error('MySQL connection test failed:', err);
    });
}

module.exports = pool; 