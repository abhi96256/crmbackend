const { db } = require('./utils/database.js');

const checkAndSetupDatabase = async () => {
  try {
    console.log('🔍 Checking database tables...');
    
    // Check if users table exists
    try {
      const [result] = await db.execute('SELECT COUNT(*) as count FROM users');
      console.log('✅ Users table exists with', result[0].count, 'users');
    } catch (error) {
      console.log('❌ Users table does not exist, creating...');
      
      // Create users table
      await db.execute(`
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          role VARCHAR(50) DEFAULT 'employee',
          avatar TEXT,
          isActive BOOLEAN DEFAULT true,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      `);
      
      // Create admin user
      const bcrypt = require('bcryptjs');
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('admin123', salt);
      
      await db.execute(`
        INSERT INTO users (name, email, password, role, isActive) 
        VALUES ('Admin User', 'admin@crm.com', $1, 'admin', true)
        ON CONFLICT (email) DO NOTHING
      `, [hashedPassword]);
      
      console.log('✅ Users table created and admin user added');
    }
    
    // Check if other essential tables exist
    const tables = [
      'leads',
      'tasks', 
      'pipeline',
      'invoices',
      'groups',
      'activity_logs'
    ];
    
    for (const table of tables) {
      try {
        const [result] = await db.execute(`SELECT COUNT(*) as count FROM ${table}`);
        console.log(`✅ ${table} table exists with`, result[0].count, 'records');
      } catch (error) {
        console.log(`❌ ${table} table does not exist`);
      }
    }
    
    console.log('🎉 Database check completed!');
    
  } catch (error) {
    console.error('❌ Database setup error:', error.message);
  }
};

// Run the check
checkAndSetupDatabase();
