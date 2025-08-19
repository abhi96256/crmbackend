# SQL Database Setup for CRM Backend

This folder contains all the SQL scripts needed to set up and maintain the CRM database.

## 🗂️ Folder Structure

```
sql/
├── setup/                    # Database table creation scripts
│   ├── 01_database.sql      # MySQL version (legacy)
│   ├── 01_database_postgresql.sql  # PostgreSQL version
│   ├── 02_users.sql         # MySQL version (legacy)
│   ├── 02_users_postgresql.sql     # PostgreSQL version
│   ├── 03_admin_tables.sql  # Admin-specific tables
│   ├── 04_groups.sql        # Groups management
│   ├── 05_emails.sql        # Email templates
│   ├── 06_invoices.sql      # Invoice management
│   ├── 07_linkedin.sql      # LinkedIn integration
│   ├── 08_tasks.sql         # Task management
│   └── 09_permissions.sql   # User permissions
├── migrations/               # Database migration scripts
│   ├── 001_add_assigned_by.sql
│   ├── 002_add_type_column.sql
│   └── 003_migrate_pipeline.sql
├── run_all_setup.sql        # Master reference for setup order
└── README.md                # This file
```

## 🚀 Quick Setup for PostgreSQL (Recommended for Render)

### Option 1: Automated Setup (Recommended)
```bash
# From the backend directory
npm run setup-postgresql
```

This will:
- Connect to your PostgreSQL database
- Create all necessary tables
- Set up the admin user (admin@crm.com / admin123)
- Handle errors gracefully

### Option 2: Manual Setup
If you prefer to run SQL manually:

1. **Create basic tables:**
   ```sql
   -- Run the contents of 01_database_postgresql.sql
   -- This creates users and activity_logs tables
   ```

2. **Set up users system:**
   ```sql
   -- Run the contents of 02_users_postgresql.sql
   -- This adds user permissions and sessions
   ```

3. **Create admin user:**
   ```sql
   INSERT INTO users (name, email, password, role, is_active) 
   VALUES ('Admin User', 'admin@crm.com', '$2a$10$...', 'admin', true);
   ```

## 🔧 Database Connection Issues

### Common Problems and Solutions

1. **"Connection terminated unexpectedly"**
   - **Cause**: PostgreSQL connection pool is unstable
   - **Solution**: Use conservative connection settings (max: 2, min: 0)
   - **Script**: Run `npm run setup-postgresql` to fix

2. **"Table does not exist"**
   - **Cause**: Database tables haven't been created
   - **Solution**: Run the setup scripts
   - **Script**: `npm run setup-postgresql`

3. **"Authentication failed"**
   - **Cause**: Wrong database credentials
   - **Solution**: Check your Render environment variables
   - **Verify**: Run `npm run test-postgresql`

### Testing Database Connection

```bash
# Test basic connection
npm run test-postgresql

# Test with retry logic
npm run test-db
```

## 📊 Database Schema

### Core Tables

- **users**: User accounts and authentication
- **activity_logs**: System activity tracking
- **leads**: Customer lead management
- **tasks**: Task assignment and tracking
- **groups**: User group management
- **invoices**: Invoice generation and tracking
- **emails**: Email template management
- **linkedin**: LinkedIn integration data

### Key Relationships

- Users can be assigned to leads, tasks, and groups
- All actions are logged in activity_logs
- Tasks can be assigned by and to users
- Leads can be assigned to users

## 🔄 Migrations

The `migrations/` folder contains scripts for updating existing databases:

1. **001_add_assigned_by.sql**: Adds assigned_by field to tasks
2. **002_add_type_column.sql**: Adds type field to various tables
3. **003_migrate_pipeline.sql**: Updates pipeline structure

## 🛠️ Environment Variables

Make sure these are set in your Render environment:

```bash
DB_DRIVER=postgresql
DATABASE_URL=postgresql://user:password@host:port/database
# OR individual variables:
DB_HOST=your-host
DB_PORT=5432
DB_USER=your-user
DB_PASSWORD=your-password
DB_NAME=your-database
```

## 🚨 Troubleshooting

### If setup fails:

1. **Check connection:**
   ```bash
   npm run test-postgresql
   ```

2. **Verify environment variables:**
   - Ensure `DB_DRIVER=postgresql`
   - Check `DATABASE_URL` format
   - Verify SSL settings

3. **Manual table creation:**
   - Connect to your database directly
   - Run SQL scripts one by one
   - Check for syntax errors

4. **Reset and retry:**
   ```bash
   # Drop and recreate tables
   npm run setup-postgresql
   ```

## 📝 Notes

- **PostgreSQL vs MySQL**: The system now supports both, but PostgreSQL is recommended for Render
- **Connection Pooling**: Conservative settings (max 2 connections) prevent Render timeouts
- **SSL**: Required for Render PostgreSQL connections
- **Admin User**: Default credentials are admin@crm.com / admin123

## 🔗 Related Files

- `backend/setup_postgresql_database.js` - Main setup script
- `backend/config/db.js` - Database configuration
- `backend/utils/database.js` - Database utility functions

