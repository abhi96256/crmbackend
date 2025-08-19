const { Pool } = require('pg');
require('dotenv').config();

console.log('🧪 Testing PostgreSQL connection...');

// Check environment variables
console.log('📋 Environment variables:');
console.log('   DB_DRIVER:', process.env.DB_DRIVER);
console.log('   DATABASE_URL:', process.env.DATABASE_URL ? 'SET' : 'NOT SET');
console.log('   DB_HOST:', process.env.DB_HOST);
console.log('   DB_PORT:', process.env.DB_PORT);
console.log('   DB_USER:', process.env.DB_USER);
console.log('   DB_NAME:', process.env.DB_NAME);
console.log('   DB_PASSWORD:', process.env.DB_PASSWORD ? 'SET' : 'NOT SET');

// Create a simple connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 1,
  idleTimeoutMillis: 10000,
  connectionTimeoutMillis: 5000,
});

const testConnection = async () => {
  let client;
  
  try {
    console.log('\n🔌 Attempting to connect...');
    client = await pool.connect();
    console.log('✅ Connection successful!');
    
    // Test a simple query
    const result = await client.query('SELECT NOW() as current_time, version() as db_version');
    console.log('✅ Query successful!');
    console.log('   Current time:', result.rows[0].current_time);
    console.log('   Database version:', result.rows[0].db_version);
    
    // Test if users table exists
    try {
      const tableResult = await client.query('SELECT COUNT(*) as user_count FROM users');
      console.log('✅ Users table exists with', tableResult.rows[0].user_count, 'users');
    } catch (tableError) {
      console.log('⚠️ Users table does not exist yet:', tableError.message);
    }
    
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    console.error('🔍 Error code:', error.code);
    console.error('🔍 Error details:', error);
  } finally {
    if (client) {
      client.release();
    }
    await pool.end();
    console.log('🔌 Connection pool closed');
  }
};

// Run the test
testConnection();


