import pool from './config/db.js';
import bcrypt from 'bcryptjs';

async function testAdminLogin() {
  try {
    console.log('🧪 Testing Admin Login...\n');
    
    // Check admin user
    const [admins] = await pool.execute(
      'SELECT * FROM users WHERE role = "admin"'
    );
    
    console.log(`Found ${admins.length} admin users`);
    
    if (admins.length === 0) {
      console.log('Creating admin user...');
      
      // Create admin user
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('admin123', salt);
      
      await pool.execute(
        'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
        ['Admin User', 'admin@crm.com', hashedPassword, 'admin']
      );
      
      console.log('✅ Admin user created!');
    }
    
    // Test admin login
    const testEmail = 'admin@crm.com';
    const testPassword = 'admin123';
    
    // Find admin user
    const [users] = await pool.execute(
      'SELECT * FROM users WHERE email = ?',
      [testEmail]
    );
    
    if (users.length === 0) {
      console.log('❌ Admin user not found');
      return;
    }
    
    const user = users[0];
    console.log(`Found admin: ${user.name} (${user.role})`);
    
    // Test password
    const isMatch = await bcrypt.compare(testPassword, user.password);
    console.log(`Password match: ${isMatch ? '✅ YES' : '❌ NO'}`);
    
    if (isMatch) {
      console.log('\n🎉 Admin login test PASSED!');
      console.log('\n📝 Admin Credentials:');
      console.log('Email: admin@crm.com');
      console.log('Password: admin123');
      console.log('\n🔗 Try logging in at: https://your-frontend-url.com/login');
    } else {
      console.log('\n❌ Admin login test FAILED!');
    }
    
    // Also test employee
    console.log('\n' + '='.repeat(40));
    console.log('🧪 Testing Employee Login...');
    
    const [employees] = await pool.execute(
      'SELECT * FROM users WHERE role = "employee"'
    );
    
    if (employees.length === 0) {
      console.log('Creating test employee...');
      
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash('password123', salt);
      
      await pool.execute(
        'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
        ['Test Employee', 'employee@test.com', hashedPassword, 'employee']
      );
      
      console.log('✅ Test employee created!');
    }
    
    console.log('\n📝 Employee Credentials:');
    console.log('Email: employee@test.com');
    console.log('Password: password123');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

testAdminLogin(); 