-- Add type column to tasks table if it doesn't exist
USE crm;

-- Check if type column exists, if not add it
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS type VARCHAR(100) DEFAULT 'Follow up'; 