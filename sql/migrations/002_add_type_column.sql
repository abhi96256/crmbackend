-- =====================================================
-- Migration: Add type column to tasks table
-- File: 002_add_type_column.sql
-- Description: Adds type column for task categorization
-- =====================================================

USE crm;

-- Add type column to tasks table if it doesn't exist
ALTER TABLE tasks 
ADD COLUMN IF NOT EXISTS type ENUM('call', 'email', 'meeting', 'follow_up', 'research', 'other') DEFAULT 'other' AFTER description;

-- Log the migration
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'MIGRATION', 'Added type column to tasks table', '127.0.0.1');

