-- =====================================================
-- CRM Database Setup - Groups Management
-- File: 04_groups.sql
-- Description: Groups and team management tables
-- =====================================================

USE crm;

-- Create groups table
CREATE TABLE IF NOT EXISTS groups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  manager_id INT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (manager_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Create group members table
CREATE TABLE IF NOT EXISTS group_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_id INT NOT NULL,
  user_id INT NOT NULL,
  role ENUM('member', 'leader', 'viewer') DEFAULT 'member',
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_group_member (group_id, user_id)
);

-- Create group permissions table
CREATE TABLE IF NOT EXISTS group_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_id INT NOT NULL,
  permission_name VARCHAR(100) NOT NULL,
  granted BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE,
  UNIQUE KEY unique_group_permission (group_id, permission_name)
);

-- Insert default groups
INSERT IGNORE INTO groups (name, description, manager_id) VALUES
('Sales Team', 'Main sales and lead generation team', 1),
('Support Team', 'Customer support and service team', 1),
('Management', 'Executive and management team', 1);

-- Add admin to all groups
INSERT IGNORE INTO group_members (group_id, user_id, role) VALUES
(1, 1, 'leader'),
(2, 1, 'leader'),
(3, 1, 'leader');

-- Log groups setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'GROUPS_SETUP', 'Groups and team management initialized', '127.0.0.1');

