// Fast environment setup script
const { Pool } = require('pg');

// Set environment variables programmatically
process.env.DB_DRIVER = 'postgresql';
process.env.NODE_ENV = 'production';

console.log('🚀 FAST SETUP - Setting environment variables...');
console.log('DB_DRIVER:', process.env.DB_DRIVER);
console.log('NODE_ENV:', process.env.NODE_ENV);

// You need to replace these with your actual Render database credentials
// Go to: https://dashboard.render.com -> Your PostgreSQL database -> Environment tab
const DATABASE_URL = 'postgresql://crm_database_elhl_user:YOUR_ACTUAL_PASSWORD@dpg-cp1234567890-a.oregon-postgres.render.com:5432/crm_database_elhl';

if (DATABASE_URL.includes('YOUR_ACTUAL_PASSWORD')) {
  console.log('');
  console.log('❌ ERROR: You need to update the DATABASE_URL with your actual password!');
  console.log('');
  console.log('🔍 STEPS TO FIX:');
  console.log('1. Go to https://dashboard.render.com');
  console.log('2. Find your PostgreSQL database service');
  console.log('3. Click on it -> Environment tab');
  console.log('4. Copy the "Internal Database URL"');
  console.log('5. Replace the DATABASE_URL in this file');
  console.log('6. Run: node setup_env.js');
  console.log('');
  console.log('Current DATABASE_URL:', DATABASE_URL);
  process.exit(1);
}

process.env.DATABASE_URL = DATABASE_URL;
console.log('✅ DATABASE_URL set successfully');

// Test connection immediately
const testConnection = async () => {
  const pool = new Pool({
    connectionString: DATABASE_URL,
    ssl: { rejectUnauthorized: false },
    max: 1,
    idleTimeoutMillis: 10000,
    connectionTimeoutMillis: 5000,
  });

  try {
    console.log('🔌 Testing database connection...');
    const client = await pool.connect();
    console.log('✅ Connection successful!');
    
    const result = await client.query('SELECT NOW() as current_time');
    console.log('✅ Database query successful:', result.rows[0].current_time);
    
    client.release();
    await pool.end();
    
    console.log('');
    console.log('🎉 Database connection working! Now running setup...');
    console.log('');
    
    // Run the database setup
    require('./setup_postgresql_database.js');
    
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
    console.log('');
    console.log('🔧 TROUBLESHOOTING:');
    console.log('1. Check if your PostgreSQL database is running on Render');
    console.log('2. Verify the DATABASE_URL is correct');
    console.log('3. Make sure SSL is enabled');
    console.log('4. Check database permissions');
  }
};

testConnection();
