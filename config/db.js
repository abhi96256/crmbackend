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
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  };
  
  pool = new Pool(pgConfig);
  
  // Test PostgreSQL connection
  pool.on('connect', () => {
    console.log('✅ Connected to PostgreSQL Database:', process.env.DB_NAME);
  });
  
  pool.on('error', (err) => {
    console.error('❌ PostgreSQL Pool Error:', err);
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