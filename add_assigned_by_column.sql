-- Add assigned_by column to tasks table
ALTER TABLE tasks ADD COLUMN assigned_by INT DEFAULT NULL;
ALTER TABLE tasks ADD FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL;
 
-- Update existing tasks to set assigned_by to user_id if not set
UPDATE tasks SET assigned_by = user_id WHERE assigned_by IS NULL; 