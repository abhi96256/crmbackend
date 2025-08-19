# 📁 SQL Database Setup

This folder contains all the SQL files needed to set up and maintain the CRM database.

## 🗂️ Folder Structure

```
sql/
├── setup/           # Database setup files (run in order)
│   ├── 01_database.sql      # Main database creation
│   ├── 02_users.sql         # User management
│   ├── 03_admin_tables.sql  # Admin functionality
│   ├── 04_groups.sql        # Team management
│   ├── 05_emails.sql        # Email system
│   ├── 06_invoices.sql      # Billing system
│   ├── 07_linkedin.sql      # LinkedIn integration
│   ├── 08_tasks.sql         # Task management
│   └── 09_permissions.sql   # Access control
├── migrations/      # Database migrations
│   ├── 001_add_assigned_by.sql
│   ├── 002_add_type_column.sql
│   └── 003_migrate_pipeline.sql
├── run_all_setup.sql        # Master setup reference
└── README.md                # This file
```

## 🚀 Quick Setup

### Option 1: Automated Setup (Recommended)
```bash
# Run the complete setup automatically
node setup_production_db.js
```

### Option 2: Manual Setup
```bash
# Run each file in order using MySQL client
mysql -u username -p < sql/setup/01_database.sql
mysql -u username -p < sql/setup/02_users.sql
# ... continue with all files
```

## 📋 Setup Order

**IMPORTANT**: Files must be run in the correct order due to dependencies:

1. **01_database.sql** - Creates database and basic tables
2. **02_users.sql** - User management system
3. **03_admin_tables.sql** - Administrative functionality
4. **04_groups.sql** - Team and group management
5. **05_emails.sql** - Email tracking system
6. **06_invoices.sql** - Billing and invoice management
7. **07_linkedin.sql** - LinkedIn integration
8. **08_tasks.sql** - Task management system
9. **09_permissions.sql** - Role-based access control

## 🔄 Migrations

Migration files can be run individually to add new features:

- **001_add_assigned_by.sql** - Adds task assignment tracking
- **002_add_type_column.sql** - Adds task categorization
- **003_migrate_pipeline.sql** - Updates pipeline structure

## 🛠️ Production Deployment

1. **Set environment variables** in your production environment
2. **Run setup script**: `node setup_production_db.js`
3. **Verify setup** by checking the `activity_logs` table
4. **Test all functionality** before going live

## 📊 Verification

After setup, verify the installation:

```sql
-- Check tables created
SHOW TABLES;

-- Check admin user
SELECT * FROM users WHERE role = 'admin';

-- Check setup progress
SELECT * FROM activity_logs ORDER BY created_at DESC;
```

## 🆘 Troubleshooting

- **Check database connection** in `config/db.js`
- **Verify file permissions** for SQL files
- **Check MySQL logs** for detailed error messages
- **Ensure proper order** of file execution

## 📝 Notes

- All files use `IF NOT EXISTS` for safe re-runs
- Activity logging tracks all setup progress
- Foreign key constraints maintain data integrity
- Sample data is included for testing

