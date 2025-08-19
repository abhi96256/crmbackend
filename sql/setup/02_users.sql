-- =====================================================
-- CRM Database Setup - Users Management
-- File: 02_users.sql
-- Description: Complete users table structure and permissions
-- =====================================================

USE crm;

-- Update users table with additional fields
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS phone VARCHAR(20) AFTER email,
ADD COLUMN IF NOT EXISTS department VARCHAR(100) AFTER role,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE AFTER department,
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP NULL AFTER is_active;

-- Create user permissions table
CREATE TABLE IF NOT EXISTS user_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  permission_name VARCHAR(100) NOT NULL,
  granted BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_permission (user_id, permission_name)
);

-- Create user sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(500) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert default permissions for admin
INSERT IGNORE INTO user_permissions (user_id, permission_name) VALUES
(1, 'USER_MANAGEMENT'),
(1, 'LEAD_MANAGEMENT'),
(1, 'TASK_MANAGEMENT'),
(1, 'INVOICE_MANAGEMENT'),
(1, 'REPORT_ACCESS'),
(1, 'SYSTEM_SETTINGS');

-- Log user setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'USER_SETUP', 'Users management system initialized', '127.0.0.1');

