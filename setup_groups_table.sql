-- Create groups table for storing user groups
CREATE TABLE IF NOT EXISTS `groups` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_by INT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- Create group_members table for many-to-many relationship between groups and emails
CREATE TABLE IF NOT EXISTS group_members (
  id INT AUTO_INCREMENT PRIMARY KEY,
  group_id INT NOT NULL,
  email VARCHAR(255) NOT NULL,
  added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (group_id) REFERENCES `groups`(id) ON DELETE CASCADE,
  UNIQUE KEY unique_group_email (group_id, email)
);

-- Insert sample groups (optional)
INSERT INTO `groups` (name, description, created_by) VALUES 
('VIP Clients', 'High priority clients for special attention', 1),
('Marketing Team', 'Internal marketing team members', 1)
ON DUPLICATE KEY UPDATE id=id;

-- Insert sample group members (optional)
INSERT INTO group_members (group_id, email) VALUES 
(1, 'john@example.com'),
(1, 'jane@example.com'),
(2, 'marketing@company.com')
ON DUPLICATE KEY UPDATE id=id; 