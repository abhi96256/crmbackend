-- =====================================================
-- CRM Complete Database Setup - Master File
-- File: run_all_setup.sql
-- Description: Runs all setup files in correct order
-- Usage: Run this file to set up the complete CRM database
-- =====================================================

-- This file will be processed by the Node.js setup script
-- It serves as a reference for the complete setup process

/*
Setup Order:
1. 01_database.sql - Creates database and basic structure
2. 02_users.sql - User management and permissions
3. 03_admin_tables.sql - Administrative functionality
4. 04_groups.sql - Team and group management
5. 05_emails.sql - Email tracking and templates
6. 06_invoices.sql - Billing and invoice management
7. 07_linkedin.sql - LinkedIn integration
8. 08_tasks.sql - Task management system
9. 09_permissions.sql - Role-based access control

Migration Files:
- 001_add_assigned_by.sql - Task assignment tracking
- 002_add_type_column.sql - Task categorization
- 003_migrate_pipeline.sql - Pipeline structure

To run the complete setup:
1. Use the Node.js script: node setup_production_db.js
2. Or run each SQL file individually in order
3. Check activity_logs table for setup progress
*/

-- This file is for reference only
-- The actual setup is handled by setup_production_db.js

