-- =====================================================
-- CRM Database Setup - Main Database Creation
-- File: 01_database.sql
-- Description: Creates the main CRM database
-- =====================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS crm;
USE crm;

-- Create basic users table structure
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user', 'manager', 'employee') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create basic activity logs table
CREATE TABLE IF NOT EXISTS activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  action VARCHAR(100) NOT NULL,
  description TEXT,
  ip_address VARCHAR(45),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert default admin user (password: admin123)
INSERT IGNORE INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@crm.com', '$2a$10$rQZ8K8K8K8K8K8K8K8K8O', 'admin');

-- Log the setup
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'SYSTEM_SETUP', 'Database initialized successfully', '127.0.0.1');

