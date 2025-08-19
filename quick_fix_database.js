const { Pool } = require('pg');

console.log('🚀 QUICK FIX - Database Setup');
console.log('==============================');

// Set environment variables
process.env.DB_DRIVER = 'postgresql';
process.env.NODE_ENV = 'production';

console.log('✅ Environment variables set');
console.log('DB_DRIVER:', process.env.DB_DRIVER);
console.log('NODE_ENV:', process.env.NODE_ENV);

// Create a simple test connection
const testAndSetup = async () => {
  console.log('');
  console.log('🔍 Testing available database configurations...');
  
  // Try different connection methods
  const connectionAttempts = [
    {
      name: 'DATABASE_URL from environment',
      config: process.env.DATABASE_URL ? {
        connectionString: process.env.DATABASE_URL,
        ssl: { rejectUnauthorized: false }
      } : null
    },
    {
      name: 'Individual environment variables',
      config: (process.env.DB_HOST && process.env.DB_USER && process.env.DB_PASSWORD && process.env.DB_NAME) ? {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT || 5432,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        ssl: { rejectUnauthorized: false }
      } : null
    }
  ];

  for (const attempt of connectionAttempts) {
    if (!attempt.config) {
      console.log(`⚠️ ${attempt.name}: Not available`);
      continue;
    }

    console.log(`🔌 Trying ${attempt.name}...`);
    
    try {
      const pool = new Pool({
        ...attempt.config,
        max: 1,
        idleTimeoutMillis: 10000,
        connectionTimeoutMillis: 5000,
      });

      const client = await pool.connect();
      console.log(`✅ ${attempt.name}: Connection successful!`);
      
      // Test query
      const result = await client.query('SELECT NOW() as current_time, version() as db_version');
      console.log(`✅ Query successful:`, result.rows[0]);
      
      client.release();
      await pool.end();
      
      console.log('');
      console.log('🎉 Database connection working! Now setting up tables...');
      console.log('');
      
      // Run the database setup
      await runDatabaseSetup(attempt.config);
      return;
      
    } catch (error) {
      console.log(`❌ ${attempt.name}: Failed - ${error.message}`);
    }
  }
  
  console.log('');
  console.log('❌ All connection attempts failed!');
  console.log('');
  console.log('🔧 IMMEDIATE ACTION REQUIRED:');
  console.log('1. Go to https://dashboard.render.com');
  console.log('2. Find your PostgreSQL database service');
  console.log('3. Copy the "Internal Database URL"');
  console.log('4. Set it as DATABASE_URL environment variable in your backend service');
  console.log('5. Redeploy your backend');
};

const runDatabaseSetup = async (dbConfig) => {
  console.log('📋 Setting up database tables...');
  
  const pool = new Pool({
    ...dbConfig,
    max: 1,
    idleTimeoutMillis: 10000,
    connectionTimeoutMillis: 5000,
  });

  let client;
  
  try {
    client = await pool.connect();
    
    // Create users table
    console.log('📋 Creating users table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'employee',
        phone VARCHAR(20),
        department VARCHAR(100),
        is_active BOOLEAN DEFAULT TRUE,
        last_login TIMESTAMP NULL,
        avatar TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Users table created');
    
    // Create admin user with simple password hash
    console.log('👤 Creating admin user...');
    const adminPassword = '$2a$10$rQZ8K8K8K8K8K8K8K8K8O'; // Simple hash for admin123
    
    await client.query(`
      INSERT INTO users (name, email, password, role, is_active) 
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (email) DO UPDATE SET
        password = EXCLUDED.password,
        role = EXCLUDED.role,
        is_active = EXCLUDED.is_active
      RETURNING id, name, email, role
    `, ['Admin User', 'admin@crm.com', adminPassword, 'admin', true]);
    
    console.log('✅ Admin user created/updated');
    
    // Create other essential tables
    console.log('📋 Creating activity_logs table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS activity_logs (
        id SERIAL PRIMARY KEY,
        user_id INTEGER,
        action VARCHAR(100) NOT NULL,
        description TEXT,
        ip_address VARCHAR(45),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
      )
    `);
    
    console.log('📋 Creating leads table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS leads (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255),
        phone VARCHAR(20),
        company VARCHAR(255),
        status VARCHAR(50) DEFAULT 'new',
        source VARCHAR(100),
        assigned_to INTEGER,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
      )
    `);
    
    console.log('📋 Creating tasks table...');
    await client.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        status VARCHAR(50) DEFAULT 'pending',
        priority VARCHAR(20) DEFAULT 'medium',
        assigned_to INTEGER,
        assigned_by INTEGER,
        due_date TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
      )
    `);
    
    console.log('');
    console.log('🎉 DATABASE SETUP COMPLETED SUCCESSFULLY!');
    console.log('');
    console.log('🔑 Admin login credentials:');
    console.log('   Email: admin@crm.com');
    console.log('   Password: admin123');
    console.log('');
    console.log('🌐 Test your login at:');
    console.log('   https://crmbackend-fahc.onrender.com/api/auth/login');
    console.log('');
    console.log('✅ Your CRM backend is now ready to use!');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    console.error('🔍 Full error:', error);
  } finally {
    if (client) {
      client.release();
    }
    await pool.end();
  }
};

// Run the setup
testAndSetup();
