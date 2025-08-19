-- =====================================================
-- Migration: Pipeline table migration
-- File: 003_migrate_pipeline.sql
-- Description: Migrates and updates pipeline structure
-- =====================================================

USE crm;

-- Create leads table if it doesn't exist
CREATE TABLE IF NOT EXISTS leads (
  id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255) UNIQUE,
  phone VARCHAR(20),
  company VARCHAR(255),
  position VARCHAR(255),
  industry VARCHAR(100),
  source VARCHAR(100) DEFAULT 'manual',
  status ENUM('new', 'contacted', 'qualified', 'proposal', 'negotiation', 'closed_won', 'closed_lost') DEFAULT 'new',
  assigned_to INT,
  assigned_by INT,
  lead_score INT DEFAULT 50,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Create pipeline stages table
CREATE TABLE IF NOT EXISTS pipeline_stages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  order_position INT NOT NULL,
  color VARCHAR(7) DEFAULT '#007bff',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default pipeline stages
INSERT IGNORE INTO pipeline_stages (name, order_position, color) VALUES
('New Lead', 1, '#28a745'),
('Contacted', 2, '#17a2b8'),
('Qualified', 3, '#ffc107'),
('Proposal', 4, '#fd7e14'),
('Negotiation', 5, '#6f42c1'),
('Closed Won', 6, '#28a745'),
('Closed Lost', 7, '#dc3545');

-- Log the migration
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'MIGRATION', 'Pipeline structure migrated successfully', '127.0.0.1');

