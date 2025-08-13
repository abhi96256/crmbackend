-- Create tasks table with all necessary columns
CREATE TABLE IF NOT EXISTS tasks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  due_date DATE,
  type VARCHAR(50) DEFAULT 'Follow up',
  status ENUM('pending', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
  priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  user_id INT NOT NULL,
  assigned_by INT,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Add indexes for better performance
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assigned_by ON tasks(assigned_by);

-- Insert some sample tasks for testing
INSERT INTO tasks (title, description, due_date, type, user_id, assigned_by) VALUES
('Follow up with client', 'Call client to discuss proposal', '2025-08-01', 'Follow up', 1, 1),
('Prepare presentation', 'Create slides for quarterly review', '2025-07-30', 'Document', 2, 1),
('Team meeting', 'Weekly team sync meeting', '2025-07-29', 'Meeting', 3, 1),
('Send proposal', 'Email proposal to potential client', '2025-08-02', 'Email', 4, 1); 