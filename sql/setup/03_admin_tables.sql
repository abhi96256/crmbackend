-- =====================================================
-- CRM Database Setup - Admin Tables
-- File: 03_admin_tables.sql
-- Description: Administrative tables and system settings
-- =====================================================

USE crm;

-- Create system settings table
CREATE TABLE IF NOT EXISTS system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  description TEXT,
  updated_by INT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create admin audit log table
CREATE TABLE IF NOT EXISTS admin_audit_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admin_id INT NOT NULL,
  action VARCHAR(100) NOT NULL,
  target_type VARCHAR(50),
  target_id INT,
  details JSON,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create system notifications table
CREATE TABLE IF NOT EXISTS system_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type ENUM('info', 'warning', 'error', 'success') DEFAULT 'info',
  is_read BOOLEAN DEFAULT FALSE,
  user_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert default system settings
INSERT IGNORE INTO system_settings (setting_key, setting_value, description) VALUES
('SYSTEM_NAME', 'CRM System', 'Name of the CRM system'),
('SYSTEM_VERSION', '1.0.0', 'Current system version'),
('MAINTENANCE_MODE', 'false', 'System maintenance mode'),
('MAX_LOGIN_ATTEMPTS', '5', 'Maximum login attempts before lockout'),
('SESSION_TIMEOUT', '3600', 'Session timeout in seconds'),
('EMAIL_NOTIFICATIONS', 'true', 'Enable email notifications');

-- Log admin setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'ADMIN_SETUP', 'Admin tables and system settings initialized', '127.0.0.1');

