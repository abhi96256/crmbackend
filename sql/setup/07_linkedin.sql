-- =====================================================
-- CRM Database Setup - LinkedIn Integration
-- File: 07_linkedin.sql
-- Description: LinkedIn integration and lead management tables
-- =====================================================

USE crm;

-- Create LinkedIn integrations table
CREATE TABLE IF NOT EXISTS linkedin_integrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  access_token TEXT NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  last_sync TIMESTAMP NULL,
  total_leads INT DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create LinkedIn leads table
CREATE TABLE IF NOT EXISTS linkedin_leads (
  id INT AUTO_INCREMENT PRIMARY KEY,
  linkedin_id VARCHAR(100) UNIQUE,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(20),
  company VARCHAR(255),
  position VARCHAR(255),
  industry VARCHAR(100),
  location VARCHAR(255),
  profile_url TEXT,
  lead_score INT DEFAULT 50,
  source VARCHAR(100) DEFAULT 'LinkedIn',
  campaign VARCHAR(255),
  status ENUM('new', 'contacted', 'qualified', 'converted', 'lost') DEFAULT 'new',
  assigned_to INT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
);

-- Create LinkedIn campaigns table
CREATE TABLE IF NOT EXISTS linkedin_campaigns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  campaign_name VARCHAR(255) NOT NULL,
  campaign_id VARCHAR(100),
  status ENUM('active', 'paused', 'completed', 'draft') DEFAULT 'draft',
  start_date DATE,
  end_date DATE,
  budget DECIMAL(10,2),
  target_audience TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create LinkedIn lead activities table
CREATE TABLE IF NOT EXISTS linkedin_lead_activities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lead_id INT NOT NULL,
  activity_type ENUM('profile_view', 'message_sent', 'connection_request', 'follow_up') NOT NULL,
  activity_data JSON,
  performed_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lead_id) REFERENCES linkedin_leads(id) ON DELETE CASCADE,
  FOREIGN KEY (performed_by) REFERENCES users(id) ON DELETE SET NULL
);

-- Insert sample LinkedIn campaign
INSERT IGNORE INTO linkedin_campaigns (campaign_name, status, start_date, end_date) VALUES
('Q1 Lead Generation', 'active', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 90 DAY));

-- Log LinkedIn setup completion
INSERT INTO activity_logs (user_id, action, description, ip_address) VALUES 
(1, 'LINKEDIN_SETUP', 'LinkedIn integration system initialized', '127.0.0.1');

