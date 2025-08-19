-- =====================================================
-- CRM Database Setup - Task Management
-- File: 08_tasks.sql
-- Description: Task management and assignment tables
-- =====================================================

USE crm;

-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  type ENUM('call', 'email', 'meeting', 'follow_up', 'research', 'other') DEFAULT 'other',
  due_date DATE,
  assigned_to INT,
  assigned_by INT,
  lead_id INT NULL,
  client_id INT NULL,
  group_id INT NULL,
  estimated_hours DECIMAL(5,2),
  actual_hours DECIMAL(5,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create task comments table
CREATE TABLE IF NOT EXISTS task_comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  user_id INT NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create task attachments table
CREATE TABLE IF NOT EXISTS task_attachments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_size INT,
  file_type VARCHAR(100),
  uploaded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create task time tracking table
CREATE TABLE IF NOT EXISTS task_time_tracking (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  user_id INT NOT NULL,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NULL,
  duration_minutes INT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert sample tasks
INSERT IGNORE INTO tasks (title, description, status, priority, type, due_date, assigned_to, assigned_by) VALUES
('Follow up with client', 'Call the client to discuss proposal details', 'pending', 'high', 'call', DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 1),
('Prepare meeting agenda', 'Create agenda for team meeting', 'pending', 'medium', 'meeting', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, 1);

-- Log tasks setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'TASKS_SETUP', 'Task management system initialized', '127.0.0.1');

