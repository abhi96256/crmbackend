import pool from './config/db.js';
import fs from 'fs';
import path from 'path';

async function setupProductionDatabase() {
  try {
    console.log('🚀 Setting up production database...\n');

    // Read SQL setup files in order
    const setupFiles = [
      'sql/setup/01_database.sql',
      'sql/setup/02_users.sql',
      'sql/setup/03_admin_tables.sql',
      'sql/setup/04_groups.sql',
      'sql/setup/05_emails.sql',
      'sql/setup/06_invoices.sql',
      'sql/setup/07_linkedin.sql',
      'sql/setup/08_tasks.sql',
      'sql/setup/09_permissions.sql'
    ];

    for (const file of setupFiles) {
      try {
        const filePath = path.join(process.cwd(), file);
        if (fs.existsSync(filePath)) {
          console.log(`📁 Processing: ${file}`);
          const sqlContent = fs.readFileSync(filePath, 'utf8');
          
          // Split SQL statements
          const statements = sqlContent
            .split(';')
            .map(stmt => stmt.trim())
            .filter(stmt => stmt.length > 0);

          for (const statement of statements) {
            if (statement.trim()) {
              try {
                await pool.execute(statement);
                console.log(`  ✅ Executed: ${statement.substring(0, 50)}...`);
              } catch (error) {
                if (error.code === 'ER_TABLE_EXISTS_ERROR' || error.code === 'ER_DUP_FIELDNAME') {
                  console.log(`  ℹ️  Skipped (already exists): ${statement.substring(0, 50)}...`);
                } else {
                  console.log(`  ⚠️  Warning: ${error.message}`);
                }
              }
            }
          }
        } else {
          console.log(`⚠️  File not found: ${file}`);
        }
      } catch (error) {
        console.log(`❌ Error processing ${file}:`, error.message);
      }
    }

    // Create admin user if not exists
    console.log('\n👤 Setting up admin user...');
    try {
      const [adminCheck] = await pool.execute(
        'SELECT id FROM users WHERE email = ?',
        ['admin@crm.com']
      );

      if (adminCheck.length === 0) {
        const bcrypt = await import('bcryptjs');
        const salt = await bcrypt.default.genSalt(10);
        const hashedPassword = await bcrypt.default.hash('admin123', salt);

        await pool.execute(
          'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
          ['Admin User', 'admin@crm.com', hashedPassword, 'admin']
        );
        console.log('✅ Admin user created successfully!');
        console.log('📝 Admin Credentials:');
        console.log('   Email: admin@crm.com');
        console.log('   Password: admin123');
      } else {
        console.log('ℹ️  Admin user already exists');
      }
    } catch (error) {
      console.log('⚠️  Warning creating admin user:', error.message);
    }

    console.log('\n🎉 Production database setup completed!');
    console.log('\n📊 Database Status:');
    
    // Check tables
    const [tables] = await pool.execute('SHOW TABLES');
    console.log(`   Tables created: ${tables.length}`);
    
    // Check users
    const [users] = await pool.execute('SELECT COUNT(*) as count FROM users');
    console.log(`   Users in system: ${users[0].count}`);

  } catch (error) {
    console.error('❌ Database setup failed:', error.message);
    console.log('\n💡 Troubleshooting tips:');
    console.log('1. Check database connection settings');
    console.log('2. Ensure database exists');
    console.log('3. Verify user permissions');
    console.log('4. Check firewall settings');
  } finally {
    await pool.end();
  }
}

// Run setup if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  setupProductionDatabase();
}

export default setupProductionDatabase;
