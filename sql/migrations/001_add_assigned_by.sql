-- =====================================================
-- Migration: Add assigned_by column to tasks table
-- File: 001_add_assigned_by.sql
-- Description: Adds assigned_by column for task assignment tracking
-- =====================================================

USE crm;

-- Add assigned_by column to tasks table if it doesn't exist
ALTER TABLE tasks 
ADD COLUMN IF NOT EXISTS assigned_by INT AFTER assigned_to,
ADD CONSTRAINT fk_tasks_assigned_by 
FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL;

-- Log the migration
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'MIGRATION', 'Added assigned_by column to tasks table', '127.0.0.1');

