const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

console.log('🚀 Starting PostgreSQL database setup...');

// Create connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 1, // Use only 1 connection for setup
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

const setupDatabase = async () => {
  let client;
  
  try {
    console.log('🔌 Connecting to PostgreSQL...');
    client = await pool.connect();
    console.log('✅ Connected to PostgreSQL successfully!');
    
    // Test basic connection
    const testResult = await client.query('SELECT NOW()');
    console.log('✅ Database connection test:', testResult.rows[0]);
    
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
    console.log('✅ Users table created/verified');
    
    // Create activity_logs table
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
    console.log('✅ Activity logs table created/verified');
    
    // Create leads table
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
    console.log('✅ Leads table created/verified');
    
    // Create tasks table
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
    console.log('✅ Tasks table created/verified');
    
    // Create admin user with proper password hash
    console.log('👤 Creating admin user...');
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('admin123', salt);
    
    const adminResult = await client.query(`
      INSERT INTO users (name, email, password, role, is_active) 
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (email) DO UPDATE SET
        password = EXCLUDED.password,
        role = EXCLUDED.role,
        is_active = EXCLUDED.is_active
      RETURNING id, name, email, role
    `, ['Admin User', 'admin@crm.com', hashedPassword, 'admin', true]);
    
    console.log('✅ Admin user created/updated:', adminResult.rows[0]);
    
    // Create basic activity log
    await client.query(`
      INSERT INTO activity_logs (user_id, action, description, ip_address) 
      VALUES ($1, $2, $3, $4)
    `, [adminResult.rows[0].id, 'SYSTEM_SETUP', 'PostgreSQL database initialized successfully', '127.0.0.1']);
    
    console.log('🎉 Database setup completed successfully!');
    console.log('🔑 Admin login credentials:');
    console.log('   Email: admin@crm.com');
    console.log('   Password: admin123');
    
  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    console.error('🔍 Full error:', error);
    
    if (error.code === '42P01') {
      console.log('💡 Table does not exist error - this is normal for first run');
    } else if (error.code === '23505') {
      console.log('💡 Duplicate key error - this is normal for repeated runs');
    }
    
  } finally {
    if (client) {
      client.release();
    }
    await pool.end();
    console.log('🔌 Database connection closed');
  }
};

// Run the setup
setupDatabase();
