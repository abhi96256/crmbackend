-- =====================================================
-- CRM Database Setup - Permissions and Access Control
-- File: 09_permissions.sql
-- Description: Role-based permissions and access control tables
-- =====================================================

USE crm;

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create permissions table
CREATE TABLE IF NOT EXISTS permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  module VARCHAR(100),
  action VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  permission_id INT NOT NULL,
  granted BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
  UNIQUE KEY unique_role_permission (role_id, permission_id)
);

-- Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  assigned_by INT,
  assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,
  UNIQUE KEY unique_user_role (user_id, role_id)
);

-- Insert default roles
INSERT IGNORE INTO roles (name, description) VALUES
('admin', 'Full system administrator with all permissions'),
('manager', 'Team manager with elevated permissions'),
('employee', 'Standard employee with basic permissions'),
('viewer', 'Read-only access to limited data');

-- Insert default permissions
INSERT IGNORE INTO permissions (name, description, module, action) VALUES
-- User Management
('USER_CREATE', 'Create new users', 'users', 'create'),
('USER_READ', 'View user information', 'users', 'read'),
('USER_UPDATE', 'Update user information', 'users', 'update'),
('USER_DELETE', 'Delete users', 'users', 'delete'),

-- Lead Management
('LEAD_CREATE', 'Create new leads', 'leads', 'create'),
('LEAD_READ', 'View lead information', 'leads', 'read'),
('LEAD_UPDATE', 'Update lead information', 'leads', 'update'),
('LEAD_DELETE', 'Delete leads', 'leads', 'delete'),

-- Task Management
('TASK_CREATE', 'Create new tasks', 'tasks', 'create'),
('TASK_READ', 'View task information', 'tasks', 'read'),
('TASK_UPDATE', 'Update task information', 'tasks', 'update'),
('TASK_DELETE', 'Delete tasks', 'tasks', 'delete'),

-- Invoice Management
('INVOICE_CREATE', 'Create new invoices', 'invoices', 'create'),
('INVOICE_READ', 'View invoice information', 'invoices', 'read'),
('INVOICE_UPDATE', 'Update invoice information', 'invoices', 'update'),
('INVOICE_DELETE', 'Delete invoices', 'invoices', 'delete'),

-- System Settings
('SYSTEM_SETTINGS', 'Access system settings', 'system', 'settings'),
('REPORTS_ACCESS', 'Access to reports and analytics', 'reports', 'access');

-- Assign permissions to admin role
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'admin';

-- Assign permissions to manager role
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'manager' 
AND p.name IN ('USER_READ', 'LEAD_CREATE', 'LEAD_READ', 'LEAD_UPDATE', 'TASK_CREATE', 'TASK_READ', 'TASK_UPDATE', 'INVOICE_READ', 'REPORTS_ACCESS');

-- Assign permissions to employee role
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'employee' 
AND p.name IN ('LEAD_READ', 'TASK_READ', 'TASK_UPDATE', 'INVOICE_READ');

-- Assign permissions to viewer role
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'viewer' 
AND p.name IN ('LEAD_READ', 'TASK_READ', 'INVOICE_READ');

-- Assign admin role to admin user
INSERT IGNORE INTO user_roles (user_id, role_id, assigned_by) VALUES (1, 1, 1);

-- Log permissions setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'PERMISSIONS_SETUP', 'Role-based permissions system initialized', '127.0.0.1');

