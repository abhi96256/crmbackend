-- =====================================================
-- CRM Database Setup - PostgreSQL Version
-- File: 01_database_postgresql.sql
-- Description: Creates the main CRM database for PostgreSQL
-- =====================================================

-- Create basic users table structure (PostgreSQL compatible)
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user' CHECK (role IN ('admin', 'user', 'manager', 'employee')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create basic activity logs table
CREATE TABLE IF NOT EXISTS activity_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  action VARCHAR(100) NOT NULL,
  description TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert default admin user (password: admin123)
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@crm.com', '$2a$10$rQZ8K8K8K8K8K8K8K8K8O', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Log the setup
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'SYSTEM_SETUP', 'Database initialized successfully', '127.0.0.1');
