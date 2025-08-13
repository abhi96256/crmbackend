-- Create database
CREATE DATABASE IF NOT EXISTS crm;
USE crm;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin', 'user', 'manager', 'employee') DEFAULT 'user',
  avatar VARCHAR(255) DEFAULT '',
  isActive BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create leads table
CREATE TABLE IF NOT EXISTS leads (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  amount DECIMAL(10,2) DEFAULT 0,
  stage VARCHAR(100) NOT NULL DEFAULT 'Initial Contact',
  pipeline VARCHAR(100) DEFAULT 'Sales Pipeline',
  contact_name VARCHAR(255),
  contact_phone VARCHAR(50),
  contact_email VARCHAR(255),
  contact_position VARCHAR(100),
  company_name VARCHAR(255),
  company_address TEXT,
  assigned_to INT,
  created_by INT,
  status ENUM('active', 'inactive', 'won', 'lost') DEFAULT 'active',
  source VARCHAR(100),
  priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  expected_close_date DATE,
  last_contact_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create notes table
CREATE TABLE IF NOT EXISTS notes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lead_id INT NOT NULL,
  content TEXT NOT NULL,
  created_by INT NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create lead_tags table (for many-to-many relationship)
CREATE TABLE IF NOT EXISTS lead_tags (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lead_id INT NOT NULL,
  tag VARCHAR(100) NOT NULL,
  FOREIGN KEY (lead_id) REFERENCES leads(id) ON DELETE CASCADE
);

-- Create tasks table for calendar
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date DATE,
  user_id INT,
  type VARCHAR(100) DEFAULT 'Follow up',
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create activity_logs table to track all CRM activities
CREATE TABLE IF NOT EXISTS activity_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  object_type ENUM('Lead', 'Contact', 'Invoice', 'Task', 'System') NOT NULL,
  object_id INT,
  object_name VARCHAR(255) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  event_description TEXT,
  value_before JSON,
  value_after JSON,
  impact ENUM('positive', 'negative', 'neutral') DEFAULT 'neutral',
  priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert default admin user (password: admin123)
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@crm.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin')
ON DUPLICATE KEY UPDATE id=id;

-- Insert sample leads
INSERT INTO leads (name, amount, stage, pipeline, contact_name, contact_phone, contact_email, company_name, assigned_to, created_by, status, source, priority) VALUES 
('John Doe', 50000.00, 'Initial', 'Sales Pipeline', 'John Doe', '+1234567890', 'john@example.com', 'ABC Corp', 1, 1, 'active', 'Website', 'high'),
('Jane Smith', 75000.00, 'Discussion', 'Sales Pipeline', 'Jane Smith', '+0987654321', 'jane@example.com', 'XYZ Inc', 1, 1, 'active', 'Referral', 'medium'),
('Mike Johnson', 100000.00, 'Proposal', 'Sales Pipeline', 'Mike Johnson', '+1122334455', 'mike@tech.com', 'Tech Solutions', 1, 1, 'active', 'Cold Call', 'high'),
('Sarah Wilson', 25000.00, 'Negotiation', 'Sales Pipeline', 'Sarah Wilson', '+1555666777', 'sarah@design.com', 'Design Studio', 1, 1, 'active', 'Social Media', 'medium'),
('David Brown', 150000.00, 'Closed', 'Sales Pipeline', 'David Brown', '+1888999000', 'david@finance.com', 'Finance Corp', 1, 1, 'won', 'Conference', 'high'),
('Emily Davis', 30000.00, 'Initial', 'Sales Pipeline', 'Emily Davis', '+1444333222', 'emily@startup.com', 'Startup Inc', 1, 1, 'active', 'Website', 'low'),
('Robert Wilson', 80000.00, 'Discussion', 'Sales Pipeline', 'Robert Wilson', '+1777888999', 'robert@consulting.com', 'Consulting Group', 1, 1, 'active', 'Referral', 'medium'),
('Lisa Anderson', 45000.00, 'Proposal', 'Sales Pipeline', 'Lisa Anderson', '+1666555444', 'lisa@retail.com', 'Retail Solutions', 1, 1, 'active', 'Cold Call', 'high')
ON DUPLICATE KEY UPDATE id=id; 

-- Insert sample activity logs
INSERT INTO activity_logs (user_id, object_type, object_id, object_name, event_type, event_description, value_before, value_after, impact, priority) VALUES 
(1, 'Lead', 1, 'Lead #1', 'Lead created', 'New lead created from website contact form', '[]', '[{"type": "Source", "value": "Website", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'medium'),
(1, 'Lead', 1, 'Lead #1', 'Sales stage changed', 'Lead moved from initial contact to discussions', '[{"type": "Pipeline", "value": "Initial contact", "color": "blue"}]', '[{"type": "Pipeline", "value": "Discussions", "color": "teal"}]', 'positive', 'medium'),
(1, 'Lead', 2, 'Lead #2', 'Lead created', 'New lead created from referral', '[]', '[{"type": "Source", "value": "Referral", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'medium'),
(1, 'Lead', 2, 'Lead #2', 'Sales stage changed', 'Lead progressed to discussion stage', '[{"type": "Pipeline", "value": "Initial contact", "color": "blue"}]', '[{"type": "Pipeline", "value": "Discussions", "color": "teal"}]', 'positive', 'medium'),
(1, 'Lead', 3, 'Lead #3', 'Lead created', 'New lead created from cold call', '[]', '[{"type": "Source", "value": "Cold Call", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'high'),
(1, 'Lead', 3, 'Lead #3', 'Sales stage changed', 'Lead moved to proposal stage', '[{"type": "Pipeline", "value": "Discussions", "color": "teal"}]', '[{"type": "Pipeline", "value": "Proposal", "color": "yellow"}]', 'positive', 'high'),
(1, 'Lead', 4, 'Lead #4', 'Lead created', 'New lead created from social media', '[]', '[{"type": "Source", "value": "Social Media", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'medium'),
(1, 'Lead', 4, 'Lead #4', 'Sales stage changed', 'Lead moved to negotiation stage', '[{"type": "Pipeline", "value": "Proposal", "color": "yellow"}]', '[{"type": "Pipeline", "value": "Negotiation", "color": "orange"}]', 'positive', 'medium'),
(1, 'Lead', 5, 'Lead #5', 'Lead created', 'New lead created from conference', '[]', '[{"type": "Source", "value": "Conference", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'high'),
(1, 'Lead', 5, 'Lead #5', 'Lead won', 'Lead successfully converted to customer', '[{"type": "Pipeline", "value": "Negotiation", "color": "orange"}]', '[{"type": "Pipeline", "value": "Closed - Won", "color": "green"}]', 'positive', 'high'),
(1, 'Lead', 6, 'Lead #6', 'Lead created', 'New lead created from website', '[]', '[{"type": "Source", "value": "Website", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'low'),
(1, 'Lead', 7, 'Lead #7', 'Lead created', 'New lead created from referral', '[]', '[{"type": "Source", "value": "Referral", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'medium'),
(1, 'Lead', 7, 'Lead #7', 'Sales stage changed', 'Lead moved to discussion stage', '[{"type": "Pipeline", "value": "Initial contact", "color": "blue"}]', '[{"type": "Pipeline", "value": "Discussions", "color": "teal"}]', 'positive', 'medium'),
(1, 'Lead', 8, 'Lead #8', 'Lead created', 'New lead created from cold call', '[]', '[{"type": "Source", "value": "Cold Call", "color": "blue"}, {"type": "Stage", "value": "Initial contact", "color": "blue"}]', 'positive', 'high'),
(1, 'Lead', 8, 'Lead #8', 'Sales stage changed', 'Lead moved to proposal stage', '[{"type": "Pipeline", "value": "Discussions", "color": "teal"}]', '[{"type": "Pipeline", "value": "Proposal", "color": "yellow"}]', 'positive', 'high'),
(1, 'Task', 1, 'Follow up call - ABC Corp', 'Task created', 'New task created for follow up call', '[]', '[{"type": "Due Date", "value": "2025-07-22", "color": "blue"}, {"type": "Priority", "value": "High", "color": "red"}]', 'positive', 'medium'),
(1, 'Task', 1, 'Follow up call - ABC Corp', 'Task completed', 'Follow up call task marked as completed', '[{"type": "Status", "value": "In Progress", "color": "yellow"}]', '[{"type": "Status", "value": "Completed", "color": "green"}]', 'positive', 'medium'),
(1, 'System', NULL, 'Activity Log', 'Data refreshed', 'Activity log data refreshed successfully', '[]', '[{"type": "Status", "value": "Updated", "color": "green"}]', 'positive', 'low')
ON DUPLICATE KEY UPDATE id=id; 