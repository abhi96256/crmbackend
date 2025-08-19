import mysql from 'mysql2/promise';
import pg from 'pg';

const { Pool } = pg;

// Determine which database driver to use
const usePostgreSQL = process.env.DB_DRIVER === 'postgresql';

let pool;

if (usePostgreSQL) {
  // PostgreSQL Configuration
  const pgConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 5432,
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    max: 20,
    min: 2,
    idleTimeoutMillis: 300000, // 5 minutes
    connectionTimeoutMillis: 30000, // 30 seconds
    acquireTimeoutMillis: 30000, // 30 seconds
    reapIntervalMillis: 1000, // Check for dead connections every second
    createTimeoutMillis: 30000, // 30 seconds to create connection
    destroyTimeoutMillis: 5000, // 5 seconds to destroy connection
  };
  
  pool = new Pool(pgConfig);
  
  // PostgreSQL connection event handlers
  pool.on('connect', (client) => {
    console.log('✅ New client connected to PostgreSQL pool');
  });
  
  pool.on('acquire', (client) => {
    console.log('✅ Client acquired from PostgreSQL pool');
  });
  
  pool.on('release', (client) => {
    console.log('✅ Client released back to PostgreSQL pool');
  });
  
  pool.on('error', (err, client) => {
    console.error('❌ PostgreSQL Pool Error:', err);
    if (client) {
      console.log('Error occurred on client:', client);
    }
  });
  
  pool.on('remove', (client) => {
    console.log('✅ Client removed from PostgreSQL pool');
  });
  
} else {
  // MySQL Configuration (for development)
  const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'your_mysql_password',
    database: process.env.DB_NAME || 'crm',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
  };
  
  pool = mysql.createPool(dbConfig);
}

// Test database connection
const testConnection = async () => {
  try {
    if (usePostgreSQL) {
      const client = await pool.connect();
      console.log('✅ PostgreSQL connection test successful');
      client.release();
    } else {
      const connection = await pool.getConnection();
      console.log('✅ MySQL connection test successful');
      connection.release();
    }
  } catch (error) {
    console.error('❌ Database connection test failed:', error.message);
  }
};

// Test connection on startup
testConnection();

export default pool; 