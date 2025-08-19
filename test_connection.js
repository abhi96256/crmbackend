const { Pool } = require('pg');

// Test PostgreSQL connection with different configurations
const testConnection = async () => {
  console.log('🔍 Testing PostgreSQL connection...');
  
  // Configuration from environment variables
  const config1 = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    ssl: { rejectUnauthorized: false },
    connectionTimeoutMillis: 10000,
  };
  
  console.log('📊 Testing with config:', {
    host: config1.host,
    port: config1.port,
    database: config1.database,
    user: config1.user,
    password: config1.password ? '***' : 'MISSING'
  });
  
  // Test 1: Basic connection
  console.log('\n🧪 Test 1: Basic connection...');
  try {
    const pool1 = new Pool(config1);
    const client = await pool1.connect();
    console.log('✅ Connection successful!');
    
    // Test query
    const result = await client.query('SELECT NOW()');
    console.log('✅ Query successful:', result.rows[0]);
    
    client.release();
    await pool1.end();
  } catch (error) {
    console.error('❌ Test 1 failed:', error.message);
    console.error('🔍 Error code:', error.code);
    console.error('🔍 Error details:', error);
  }
  
  // Test 2: Connection with DATABASE_URL (if available)
  if (process.env.DATABASE_URL) {
    console.log('\n🧪 Test 2: Using DATABASE_URL...');
    try {
      const pool2 = new Pool({
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }
      });
      
      const client = await pool2.connect();
      console.log('✅ DATABASE_URL connection successful!');
      
      const result = await client.query('SELECT NOW()');
      console.log('✅ Query successful:', result.rows[0]);
      
      client.release();
      await pool2.end();
    } catch (error) {
      console.error('❌ Test 2 failed:', error.message);
    }
  } else {
    console.log('\n⚠️ DATABASE_URL not found in environment variables');
  }
  
  // Test 3: List all environment variables related to DB
  console.log('\n📋 Environment variables:');
  const envVars = Object.keys(process.env).filter(key => 
    key.includes('DB_') || key.includes('DATABASE') || key.includes('POSTGRES')
  );
  
  envVars.forEach(key => {
    const value = key.includes('PASSWORD') ? '***' : process.env[key];
    console.log(`   ${key}: ${value}`);
  });
  
  process.exit(0);
};

testConnection();



